require "spec_helper"

RSpec.describe Asciidoctor::Gb do
  it "processes sections" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      
      .Foreword

      Text

      == 引言

      === Introduction Subsection

      === Patent Notice

      == 范围

      Text

      == 规范性引用文件

      == 术语和定义

      === Term1

      == 术语、定义、符号、代号和缩略语

      === Normal Terms

      ==== Term2

      === 符号、代号和缩略语

      == 符号、代号和缩略语

      == Clause 4

      === Introduction

      === Clause 4.2

      [appendix]
      == Annex

      === Annex A.1

      [%appendix]
      === Appendix 1

      == 参考文献

      === Bibliography Subsection
    INPUT
            #{BLANK_HDR}
       <preface><foreword obligation="informative">
         <title>Foreword</title>
         <p id="_">Text</p>
       </foreword><introduction id="_" obligation="informative"><title>Introduction</title><clause id="_" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
     
       <clause id="_" obligation="normative">
         <title>Scope</title>
         <p id="_">Text</p>
       </clause>
     
       <terms id="_" obligation="normative">
         <title>Terms and Definitions</title>
         <term id="_">
         <preferred language="zh">1</preferred> <preferred language="en">Term1</preferred>
       </term>
       </terms>
       <clause id="_" obligation="normative"><title>Terms and Definitions</title><terms id="_" obligation="normative">
         <title>Normal Terms</title>
         <term id="_">
         <preferred language="zh">2</preferred> <preferred language="en">Term2</preferred>
       </term>
       </terms>
       <definitions id="_"/></clause>
       <definitions id="_"/>
       <clause id="_" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="_" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>
     
       </sections><annex id="_" inline-header="false" obligation="normative"><title>Annex</title><clause id="_" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
       </clause>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Appendix 1</title>
       </clause></annex><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
       </references><clause id="_" obligation="informative">
         <title>Bibliography</title>
         <references id="_" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause></bibliography>
       </gb-standard>
OUTPUT
  end
end