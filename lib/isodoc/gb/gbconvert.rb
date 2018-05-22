require "isodoc"
require_relative "./i18n.rb"
require_relative "./gbcleanup.rb"
require_relative "./xref_gen.rb"
require_relative "./metadata.rb"
require_relative "./agencies.rb"
require_relative "./section_output.rb"
require_relative "./block_output.rb"

module IsoDoc
  module Gb
    # A {Converter} implementation that generates GB output, and a document
    # schema encapsulation of the document for validation
    class Convert < IsoDoc::Convert
      def default_fonts(options)
        script = options[:script] || "Hans"
        b = options[:bodyfont] ||
          (script == "Hans" ? '"SimSun",serif' :
           script == "Latn" ? '"Cambria",serif' : '"SimSun",serif' )
        h = options[:headerfont] ||
          (script == "Hans" ? '"SimHei",sans-serif' :
           script == "Latn" ? '"Calibri",sans-serif' : '"SimHei",sans-serif' )
        m = options[:monospacefont] || '"Courier New",monospace'
        scope = options[:scope] || "national"
        t = options[:titlefont] ||
          (scope == "national" ? (script != "Hans" ? '"Cambria",serif' : '"SimSun",serif' ) :
           (script == "Hans" ? '"SimHei",sans-serif' : '"Calibri",sans-serif' ))
        "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n$titlefont: #{t};\n"
      end

      def initialize(options)
        super
        @htmlstylesheet = generate_css(html_doc_path("htmlstyle.scss"), true, default_fonts(options))
        @standardstylesheet = generate_css(html_doc_path("gb.scss"), true, default_fonts(options))
        @htmlcoverpage = html_doc_path("html_gb_titlepage.html")
        @htmlintropage = html_doc_path("html_gb_intro.html")
        @scripts = html_doc_path("scripts.html")
      end

      def html_doc_path(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def middle(isoxml, out)
        super
        end_line(isoxml, out)
      end

      def end_line(_isoxml, out)
        out.hr **{ width: "25%" }
      end

      def error_parse(node, out)
        # catch elements not defined in ISO
        case node.name
        when "string" then string_parse(node, out)
        else
          super
        end
      end

      def string_parse(node, out)
        if node["script"] == "Hant"
          out.span **{ class: "Hant" } do |s|
            node.children.each { |c| parse(c, s) }
          end
        else
          node.children.each { |c| parse(c, out) }
        end
      end

      def fileloc(loc)
        File.join(File.dirname(__FILE__), loc)
      end

      def deprecated_term_parse(node, out)
        out.p **{ class: "DeprecatedTerms" } do |p|
          p << l10n("#{@deprecated_lbl}: ")
          node.children.each { |c| parse(c, p) }
        end
      end

      def local_logo_suffix(scope)
        return "" if scope != "local"
        local = get_metadata[:docidentifier][2,2]
        "<span style='font-weight:bold'>#{local}</span>"
      end

      def format_logo(prefix, scope, _format)
        return "" if %w(enterprise social).include? scope
        logo = standard_logo(prefix)
        if logo.nil?
          "<span style='font-size:36pt;font-weight:bold'>#{prefix}</span>"
        else
          format_logo1(logo, prefix, scope)
        end
      end

      def format_logo1(logo, prefix, scope)
        logo += ".gif"
        system "cp #{fileloc(File.join('html/gb-logos', logo))}  #{logo}"
        local = local_logo_suffix(scope)
        @files_to_delete << logo
        "<img width='113' height='56' src='#{logo}' alt='#{prefix}'></img>"\
          "#{local}"
      end

      def format_agency(agency, format)
        return agency unless agency.is_a?(Array)
        if agency == ["中华人民共和国国家质量监督检验检疫总局", "中国国家标准化管理委员会"]
          logo = "gb-issuer-default.gif"
          system "cp #{fileloc(File.join('html/gb-logos', logo))}  #{logo}"
          return "<img src='#{logo}' alt='#{agency.join(",")}'></img>"
        end
        format_agency1(agency, format)
      end

      def format_agency1(agency, format)
        ret = "<table>"
        agency.each { |a| ret += "<tr><td>#{a}</td></tr>" }
        ret += "</table>"
        ret.gsub!(/<table>/, "<table width='100%'>") if format == :word
        ret
      end

      def termref_render(x)
        parts = x.split(%r{(\s*\[MODIFICATION\]|,)}m)
        parts[1] = l10n(", #{@source_lbl}") if parts.size > 1 && parts[1] == ","
        parts.map do |p|
          /\s*\[MODIFICATION\]/.match?(p) ? l10n(", #{@modified_lbl} &mdash; ") : p
        end.join.sub(/\A\s*/m, l10n("[")).sub(/\s*\z/m, l10n("]"))
      end

      def termref_resolve(docxml)
        docxml.split(%r{(\[TERMREF\]|\[/TERMREF\])}).each_slice(4).
          map do |a|
          a.size < 3 ? a[0] : a[0] + termref_render(a[2])
        end.join
      end

      def populate_template(docxml, format)
        meta = get_metadata.merge(@labels)
        logo = format_logo(meta[:gbprefix], meta[:gbscope], format)
        docxml = termref_resolve(docxml)
        meta[:standard_agency_formatted] =
          format_agency(meta[:standard_agency], format)
        meta[:standard_logo] = logo
        template = Liquid::Template.parse(docxml)
        template.render(meta.map { |k, v| [k.to_s, v] }.to_h)
      end
    end
  end
end