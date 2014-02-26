unit OXmlTestUnit;

{$DEFINE USE_DELPHIXML}//define/undefine to compare OXml with Delphi XML
{$DEFINE USE_MSXML}//define/undefine to compare OXml with MS XML
{.$DEFINE USE_OMNIXML}//define/undefine to compare OXml with OmniXML
{.$DEFINE USE_NATIVEXML}//define/undefine to compare OXml with NativeXML
{.$DEFINE USE_VERYSIMPLE}//define/undefine to compare OXml with VerySimpleXML: http://blog.spreendigital.de/2011/11/10/verysimplexml-a-lightweight-delphi-xml-reader-and-writer/
{.$DEFINE USE_SIMPLEXML}//define/undefine to compare OXml with SimpleXML: http://www.audio-data.de/simplexml.html
{.$DEFINE USE_DIXML}//define/undefine to compare OXml with DIXml: http://www.yunqa.de/delphi/doku.php/products/xml/index?DokuWiki=kg5ade2rod3o49f5v1anmf7ol1
{.$DEFINE USE_ALCINOE}//define/undefine to compare OXml with Alcinoe: https://sourceforge.net/projects/alcinoe/
{.$DEFINE USE_LAZARUSDOMXML}//define/undefine to compare OXml with Lazarus DOM XML

{$IFDEF FPC}
  {$DEFINE USE_FORIN}
{$ELSE}
  {$IF CompilerVersion >= 20}//D2009
    {$DEFINE USE_FORIN}
    {$DEFINE USE_ANONYMOUS_METHODS}
  {$IFEND}
  {$IF CompilerVersion >= 23}//DXE2
    {$DEFINE USE_ADOM}
  {$IFEND}
{$ENDIF}

interface

uses
  {$IFDEF FPC}LCLIntf, {$ELSE}Windows, {$ENDIF}
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  //BEGIN XML LIBRARIES UNITS
  {$IFDEF USE_DELPHIXML}
  XMLIntf, XMLDoc, xmldom, msxmldom, {$IFDEF USE_ADOM}adomxmldom,{$ENDIF} OXmlDOMVendor,
  {$ENDIF}
  {$IFDEF USE_MSXML}
  msxml, {$IFNDEF USE_DELPHIXML}msxmldom,{$ENDIF}
  {$ENDIF}
  {$IFDEF USE_OMNIXML}
  OmniXML,
  {$ENDIF}
  {$IFDEF USE_NATIVEXML}
  NativeXml,
  {$ENDIF}
  {$IFDEF USE_VERYSIMPLE}
  Xml.VerySimple,
  {$ENDIF}
  {$IFDEF USE_SIMPLEXML}
  SimpleXML,
  {$ENDIF}
  {$IFDEF USE_DIXML}
  DIXml,
  {$ENDIF}
  {$IFDEF USE_ALCINOE}
  AlXmlDoc, AlStringList,
  {$ENDIF}
  {$IFDEF USE_LAZARUSDOMXML}
  XMLRead, XMLWrite, DOM, SAX, SAX_XML,
  {$ENDIF}
  //END XML LIBRARIES UNITS
  OEncoding, OWideSupp, OTextReadWrite, OXmlReadWrite, OXmlUtils,
  OXmlCDOM, OXmlPDOM, OXmlSAX, OXmlSeq;

type
  TForm1 = class(TForm)
    LblTimeInfo: TLabel;
    BtnReadPerformanceTest: TButton;
    BtnWritePerformanceTest: TButton;
    BtnResaveTest: TButton;
    BtnAttributeTest: TButton;
    BtnXmlDirectWrite: TButton;
    BtnTestSAX: TButton;
    BtnDOMTest: TButton;
    BtnIterateTest: TButton;
    BtnSequentialTest: TButton;
    BtnTestXPath: TButton;
    BtnTestReadInvalid: TButton;
    BtnTestWriteInvalid: TButton;
    BtnEncodingTest: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure BtnXmlDirectWriteClick(Sender: TObject);
    procedure BtnReadPerformanceTestClick(Sender: TObject);
    procedure BtnTestXPathClick(Sender: TObject);
    procedure BtnTestSAXClick(Sender: TObject);
    procedure BtnWritePerformanceTestClick(Sender: TObject);
    procedure BtnTestWriteInvalidClick(Sender: TObject);
    procedure BtnEncodingTestClick(Sender: TObject);
    procedure BtnIterateTestClick(Sender: TObject);
    procedure BtnSequentialTestClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BtnTestReadInvalidClick(Sender: TObject);
    procedure BtnDOMTestClick(Sender: TObject);
    procedure BtnResaveTestClick(Sender: TObject);
    procedure BtnAttributeTestClick(Sender: TObject);
  private
    procedure DoNothing(const {%H-}aStr1, {%H-}aStr2: OWideString);

    procedure MatchTestFiles(const aFileSource, aFileTarget: OWideString);

    procedure Navigate_SAXStartElement(Sender: TSAXParser; const aName: OWideString;
      const aAttributes: TSAXAttributes);
    procedure Navigate_SAXEndElement(Sender: TSAXParser; const {%H-}aName: OWideString);

    {$IFDEF USE_LAZARUSDOMXML}
    procedure Navigate_LazarusSAXStartElement(Sender: TObject;
      const {%H-}NamespaceURI, LocalName, {%H-}QName: SAXString;
      Atts: SAX.TSAXAttributes);
    procedure Navigate_LazarusSAXEndElement(Sender: TObject;
      const {%H-}NamespaceURI, {%H-}LocalName, {%H-}QName: SAXString);
    {$ENDIF}
    {$IFDEF USE_ALCINOE}
    procedure Navigate_AlcinoeSAXStartElement(Sender: TObject; const Path, Name: AnsiString; const Attributes: TALStrings);
    {$ENDIF}
  private
    DocDir: String;

    procedure SAXStartDocument(Sender: TSAXParser);
    procedure SAXEndDocument(Sender: TSAXParser);
    procedure SAXCharacters(Sender: TSAXParser; const aText: OWideString);
    procedure SAXComment(Sender: TSAXParser; const aText: OWideString);
    procedure SAXProcessingInstruction(Sender: TSAXParser; const aTarget, aContent: OWideString);
    procedure SAXStartElement(Sender: TSAXParser; const aName: OWideString;
      const aAttributes: TSAXAttributes);
    procedure SAXEndElement(Sender: TSAXParser; const aName: OWideString);
  protected
    procedure DoCreate; override;
  end;

function SAXEscapeString(const aString: OWideString): OWideString;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BtnReadPerformanceTestClick(Sender: TObject);
  {$IFDEF USE_DELPHIXML}
  procedure TestDelphiXmlDOM(const aVendorName: String);
    procedure _Navigate(const aNode: XMLIntf.IXmlNode);
    var
      I: Integer;
      xCNode: XMLIntf.IXmlNode;
    begin
      for I := 0 to aNode.AttributeNodes.Count-1 do
      begin
        xCNode := aNode.AttributeNodes[I];
        DoNothing(xCNode.NodeName, xCNode.NodeValue);
      end;

      if aNode.HasChildNodes then
      for I := 0 to aNode.ChildNodes.Count-1 do
      begin
        xCNode := aNode.ChildNodes[I];
        DoNothing(xCNode.NodeName, '');
        if xCNode.NodeType = XMLIntf.ntElement then
          _Navigate(xCNode);
      end;
    end;
  var
    xXml: XMLDoc.TXMLDocument;
    xXmlIntf: XMLIntf.IXMLDocument;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;

    xXml := XMLDoc.TXMLDocument.Create(nil);
    xXmlIntf := xXml;

    xXml.DOMVendor := xmldom.GetDOMVendor(aVendorName);
    xXml.LoadFromFile(DocDir+'sheet1.xml');
    xXml.Active := True;
    xT2 := GetTickCount;

    _Navigate(xXml.Node);

    xXmlIntf := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'DELPHI XML with "'+aVendorName+'" vendor'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}
  {$IFDEF USE_MSXML}
  procedure TestMSXmlDOM;
    procedure _Navigate(const aNode: msxml.IXmlDOMNode);
    var
      I: Integer;
      xCNode: msxml.IXmlDOMNode;
    begin
      if Assigned(aNode.attributes) then begin
        for I := 0 to aNode.attributes.length-1 do
        begin
          xCNode := aNode.attributes.item[I];
          DoNothing(xCNode.NodeName, xCNode.NodeValue);
        end;
      end;

      if aNode.HasChildNodes then
      for I := 0 to aNode.ChildNodes.length-1 do
      begin
        xCNode := aNode.ChildNodes[I];
        DoNothing(xCNode.NodeName, '');
        if xCNode.NodeType = msxml.NODE_ELEMENT then
          _Navigate(xCNode);
      end;
    end;
  var
    xXml: msxml.IXMLDOMDocument;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := msxmldom.CreateDOMDocument;
    xXml.load(DocDir+'sheet1.xml');
    xT2 := GetTickCount;
    _Navigate(xXML);

    xXml := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'MS XML DOM'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_OMNIXML}
  procedure TestOmniXmlDOM;
    procedure _Navigate(const aNode: OmniXml.IXMLNode);
    var
      I: Integer;
      xCNode: OmniXml.IXMLNode;
    begin
      if Assigned(aNode.attributes) then begin
        for I := 0 to aNode.attributes.length-1 do
        begin
          xCNode := aNode.attributes.item[I];
          DoNothing(xCNode.NodeName, xCNode.NodeValue);
        end;
      end;

      if aNode.HasChildNodes then
      for I := 0 to aNode.ChildNodes.length-1 do
      begin
        xCNode := aNode.ChildNodes.Item[I];
        DoNothing(xCNode.NodeName, '');
        if xCNode.NodeType = OmniXML.ELEMENT_NODE then
          _Navigate(xCNode);
      end;
    end;
  var
    xXml: OmniXml.IXMLDocument;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := OmniXml.CreateXMLDoc;
    //xXml.WhiteSpaceHandling := OmniXML.wsPreserveAll;//enable/disable according to OmniXML mod
    xXml.PreserveWhiteSpace := True;//enable/disable according to OmniXML mod
    xXml.Load(DocDir+'sheet1.xml');
    xT2 := GetTickCount;
    _Navigate(xXML);

    xXml := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OmniXML DOM'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_NATIVEXML}
  procedure TestNativeXmlDOM;
    procedure _Navigate(const aNode: NativeXml.TXmlNode);
    var
      I: Integer;
      xCNode: NativeXml.TXmlNode;
    begin
      for I := 0 to aNode.AttributeCount-1 do
      begin
        xCNode := aNode.Attributes[I];
        DoNothing(xCNode.NameUnicode, xCNode.ValueUnicode);
      end;

      for I := 0 to aNode.ElementCount-1 do
      begin
        xCNode := aNode.Elements[I];
        DoNothing(xCNode.NameUnicode, '');
        if xCNode.ElementType = NativeXml.xeElement then
          _Navigate(xCNode);
      end;
    end;
  var
    xXml: NativeXml.TNativeXml;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := NativeXml.TNativeXml.Create(nil);
    try
      xXml.XmlFormat := NativeXml.xfPreserve;
      xXml.LoadFromFile(DocDir+'sheet1.xml');
      xT2 := GetTickCount;
      _Navigate(xXml.Root);

      FreeAndNil(xXml);

      xT3 := GetTickCount;

      Memo1.Lines.Text :=
        Memo1.Lines.Text+sLineBreak+
        'NativeXml DOM'+sLineBreak+
        'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
        'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
        'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
        sLineBreak+sLineBreak;
    finally
      xXml.Free;
    end;
  end;
  {$ENDIF}

  {$IFDEF USE_VERYSIMPLE}
  procedure TestVerySimpleXmlDOM;
  var
    xXml: Xml.VerySimple.TXmlVerySimple;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := Xml.VerySimple.TXmlVerySimple.Create;
    try
      xXml.LoadFromFile(DocDir+'sheet1.xml');
      xT2 := GetTickCount;

      //navigate -> not necessary, VerySimple fails to read the file

      FreeAndNil(xXml);

      xT3 := GetTickCount;

      Memo1.Lines.Text :=
        Memo1.Lines.Text+sLineBreak+
        'VerySimpleXML DOM'+sLineBreak+
        'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
        'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
        'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
        sLineBreak+sLineBreak;
    finally
      xXml.Free;
    end;
  end;
  {$ENDIF}

  {$IFDEF USE_SIMPLEXML}
  procedure TestSimpleXmlDOM;
    procedure _Navigate(const aNode: SimpleXML.IXMLNode);
    var
      I: Integer;
      xCNode: SimpleXML.IXmlNode;
    begin
      for I := 0 to aNode.AttrCount-1 do
      begin
        DoNothing(aNode.AttrNames[I], aNode.GetAttr(aNode.AttrNameIDs[I]));
      end;

      if Assigned(aNode.ChildNodes) then
      for I := 0 to aNode.ChildNodes.Count-1 do
      begin
        xCNode := aNode.ChildNodes[I];
        DoNothing(xCNode.NodeName, '');
        if xCNode.NodeType = SimpleXML.NODE_ELEMENT then
          _Navigate(xCNode);
      end;
    end;
  var
    xXml: SimpleXML.IXmlDocument;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := SimpleXML.CreateXmlDocument;
    xXml.PreserveWhiteSpace := True;
    xXml.Load(DocDir+'sheet1.xml');
    xT2 := GetTickCount;
    _Navigate(xXml);

    xXml := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'SimpleXML DOM'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_DIXML}
  procedure TestDIXmlDOM;
    procedure _Navigate(const aNode: DIXml.xmlNodePtr);
    var
      xCNode: DIXml.xmlNodePtr;
      xCAttr: DIXml.xmlAttrPtr;
      xAttrValue: PAnsiChar;
    begin
      xCAttr := aNode.Properties;
      while Assigned(xCAttr) do
      begin
        xAttrValue := xmlGetProp(aNode, xCAttr.Name);
        DoNothing(
          {$IFNDEF FPC}{$IFDEF UNICODE}UTF8ToString{$ELSE}UTF8Decode{$ENDIF}{$ENDIF}(xCAttr.Name),
          {$IFNDEF FPC}{$IFDEF UNICODE}UTF8ToString{$ELSE}UTF8Decode{$ENDIF}{$ENDIF}(xAttrValue));
        FreeMem(xAttrValue);
        xCAttr := xCAttr.Next;
      end;

      xCNode := aNode.Children;
      while Assigned(xCNode) do
      begin
        DoNothing({$IFNDEF FPC}{$IFDEF UNICODE}UTF8ToString{$ELSE}UTF8Decode{$ENDIF}{$ENDIF}(xCNode.Name), '');
        if xCNode.Type_ = DIXml.XML_ELEMENT_NODE then
          _Navigate(xCNode);
        xCNode := xCNode.Next;
      end;
    end;
  var
    xXml: DIXml.xmlDocPtr;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;
    DIXml.xmlInitParser;
    xXml := DIXml.xmlReadFile(PAnsiChar({$IFNDEF FPC}UTF8Encode{$ENDIF}(DocDir+'sheet1.xml')), nil, 0);
    xT2 := GetTickCount;
    _Navigate(DIXml.xmlDocGetRootElement(xXml));

    DIXml.xmlFreeDoc(xXml);
    DIXml.xmlCleanupParser;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'DIXml DOM'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_ALCINOE}
  procedure TestAlcinoeDOM;
    procedure _Navigate(const aNode: AlXmlDoc.TALXMLNode);
    var
      I: Integer;
      xCNode: AlXmlDoc.TALXMLNode;
    begin
      if Assigned(aNode.AttributeNodes) then
      for I := 0 to aNode.AttributeNodes.Count-1 do
      begin
        xCNode := aNode.AttributeNodes[I];
        DoNothing(
          {$IFNDEF FPC}{$IFDEF UNICODE}UTF8ToString{$ELSE}UTF8Decode{$ENDIF}{$ENDIF}(xCNode.NodeName),
          {$IFNDEF FPC}{$IFDEF UNICODE}UTF8ToString{$ELSE}UTF8Decode{$ENDIF}{$ENDIF}(xCNode.NodeValue));
      end;

      if aNode.HasChildNodes then
      for I := 0 to aNode.ChildNodes.Count-1 do
      begin
        xCNode := aNode.ChildNodes[I];
        DoNothing({$IFNDEF FPC}{$IFDEF UNICODE}UTF8ToString{$ELSE}UTF8Decode{$ENDIF}{$ENDIF}(xCNode.NodeName), '');
        if xCNode.NodeType = AlXmlDoc.ntElement then
          _Navigate(xCNode);
      end;
    end;
  var
    xXml: AlXmlDoc.TALXMLDocument;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;

    xXml := AlXmlDoc.TALXMLDocument.Create;
    try
      xXml.LoadFromFile(AnsiString(DocDir+'sheet1.xml'));
      xXml.Active := True;
      xT2 := GetTickCount;

      _Navigate(xXml.Node);

      xXml.Free;
      xXml := nil;

      xT3 := GetTickCount;
    finally
      xXml.Free;
    end;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'Alcinoe DOM'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure TestAlcinoeSAX;
  var
    xSAX: AlXmlDoc.TALXMLDocument;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;

    //read
    xSAX := AlXmlDoc.TALXMLDocument.Create;
    try
      xSAX.LoadFromFile(AnsiString(DocDir+'sheet1.xml'), True);
    finally
      xSAX.Free;
    end;

    xT2 := GetTickCount;

    //read+navigate
    xSAX := AlXmlDoc.TALXMLDocument.Create;
    try
      xSAX.OnParseStartElement := Navigate_AlcinoeSAXStartElement;
      xSAX.LoadFromFile(AnsiString(DocDir+'sheet1.xml'), True);
    finally
      xSAX.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'Alcinoe SAX'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((Integer(xT3-xT2)-Integer(xT2-xT1)) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_LAZARUSDOMXML}
  procedure TestLazarusDOM;
    procedure _Navigate(const aNode: DOM.TDOMNode);
    var
      xCNode: DOM.TDOMNode;
      I: Integer;
    begin
      if aNode.HasAttributes then
      begin
        for I := 0 to aNode.Attributes.Length-1 do
        begin
          xCNode := aNode.Attributes[I];
          DoNothing(xCNode.NodeName, xCNode.NodeValue);
        end;
      end;

      if aNode.HasChildNodes then
      begin
        xCNode := aNode.FirstChild;
        while Assigned(xCNode) do
        begin
          DoNothing(xCNode.NodeName, '');
          if xCNode.NodeType = DOM.ELEMENT_NODE then
            _Navigate(xCNode);
          xCNode := xCNode.NextSibling;
        end;
      end;
    end;
  var
    xXml: DOM.TXMLDocument;
    xT1, xT2, xT3: Cardinal;
  begin
    xXml := nil;
    try
      xT1 := GetTickCount;
      XMLRead.ReadXMLFile(xXml, DocDir+'sheet1.xml');
      xT2 := GetTickCount;
      _Navigate(xXml);
    finally
      xXml.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'Lazarus XML DOM'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure TestLazarusSAX;
  var
    xSAX: SAX_XML.TSAXXMLReader;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;

    //read
    xSAX := SAX_XML.TSAXXMLReader.Create;
    try
      xSAX.Parse(DocDir+'sheet1.xml');
    finally
      xSAX.Free;
    end;

    xT2 := GetTickCount;

    //read+navigate
    xSAX := SAX_XML.TSAXXMLReader.Create;
    try
      xSAX.OnStartElement := Navigate_LazarusSAXStartElement;
      xSAX.OnEndElement := Navigate_LazarusSAXEndElement;

      xSAX.Parse(DocDir+'sheet1.xml');
    finally
      xSAX.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'Lazarus SAX'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((Integer(xT3-xT2)-Integer(xT2-xT1)) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  procedure TestOXmlCDOM;
    procedure _Navigate(const aNode: OXmlCDOM.TXMLNode);
    var
      xCNode: OXmlCDOM.TXMLNode;
    begin
      if aNode.HasAttributes then begin
        xCNode := aNode.FirstAttribute;
        while Assigned(xCNode) do
        begin
          DoNothing(xCNode.NodeName, xCNode.NodeValue);
          xCNode := xCNode.NextSibling;
        end;
      end;

      if aNode.HasChildNodes then begin
        xCNode := aNode.FirstChild;
        while Assigned(xCNode) do
        begin
          DoNothing(xCNode.NodeName, '');
          if xCNode.NodeType = OXmlUtils.ntElement then
            _Navigate(xCNode);
          xCNode := xCNode.NextSibling;
        end;
      end;
    end;
  var
    xXml: OXmlCDOM.IXMLDocument;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := OXmlCDOM.CreateXMLDoc;
    xXml.WhiteSpaceHandling := wsPreserveAll;
    xXml.LoadFromFile(DocDir+'sheet1.xml');
    xT2 := GetTickCount;
    _Navigate(xXml.Node);

    xXml := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml class DOM'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure TestOXmlPDOM;
    procedure _Navigate(const aNode: OXmlPDOM.PXMLNode);
    var
      xCNode: OXmlPDOM.PXMLNode;
    begin
      if aNode.HasAttributes then begin
        xCNode := aNode.FirstAttribute;
        while Assigned(xCNode) do
        begin
          DoNothing(xCNode.NodeName, xCNode.NodeValue);
          xCNode := xCNode.NextSibling;
        end;
      end;

      if aNode.HasChildNodes then begin
        xCNode := aNode.FirstChild;
        while Assigned(xCNode) do
        begin
          DoNothing(xCNode.NodeName, '');
          if xCNode.NodeType = OXmlUtils.ntElement then
            _Navigate(xCNode);
          xCNode := xCNode.NextSibling;
        end;
      end;
    end;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.WhiteSpaceHandling := wsPreserveAll;
    xXml.LoadFromFile(DocDir+'sheet1.xml');
    xT2 := GetTickCount;
    _Navigate(xXml.Node);

    xXml := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml record DOM'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure TestOXmlSAX;
  var
    xSAX: TSAXParser;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;

    //read
    xSAX := TSAXParser.Create;
    try
      xSAX.ParseFile(DocDir+'sheet1.xml');
    finally
      xSAX.Free;
    end;

    xT2 := GetTickCount;

    //read+navigate
    xSAX := TSAXParser.Create;
    try
      xSAX.OnStartElement := Navigate_SAXStartElement;
      xSAX.OnEndElement := Navigate_SAXEndElement;

      xSAX.ParseFile(DocDir+'sheet1.xml');
    finally
      xSAX.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml SAX'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((Integer(xT3-xT2)-Integer(xT2-xT1)) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure TestOXmlSeq;
    procedure _Navigate(const aNode: OXmlPDOM.PXMLNode);
    var
      xCNode: OXmlPDOM.PXMLNode;
    begin
      if aNode.HasAttributes then begin
        xCNode := aNode.FirstAttribute;
        while Assigned(xCNode) do
        begin
          DoNothing(xCNode.NodeName, xCNode.NodeValue);
          xCNode := xCNode.NextSibling;
        end;
      end;

      if aNode.HasChildNodes then begin
        xCNode := aNode.FirstChild;
        while Assigned(xCNode) do
        begin
          DoNothing(xCNode.NodeName, '');
          if xCNode.NodeType = OXmlUtils.ntElement then
            _Navigate(xCNode);
          xCNode := xCNode.NextSibling;
        end;
      end;
    end;
  var
    xSeq: TXMLSeqParser;
    xT1, xT2, xT3: Cardinal;
    xDataIsOpen: Boolean;
    xRowNode: PXMLNode;
  begin
    xT1 := GetTickCount;

    //read
    xSeq := TXMLSeqParser.Create;
    try
      xSeq.InitFile(DocDir+'sheet1.xml');

      xSeq.GoToPath('/worksheet/sheetData');
      xSeq.SkipNextChildElementHeader({%H-}xDataIsOpen);
      if xDataIsOpen then
      begin
        while xSeq.ReadNextChildNode({%H-}xRowNode) do
        begin
          //nothing
        end;
      end;

      xSeq.GoToPath('/');//go to end
    finally
      xSeq.Free;
    end;

    xT2 := GetTickCount;

    //read + navigate
    xSeq := TXMLSeqParser.Create;
    try
      xSeq.InitFile(DocDir+'sheet1.xml');

      xSeq.GoToPath('/worksheet/sheetData');
      xSeq.SkipNextChildElementHeader(xDataIsOpen);
      if xDataIsOpen then
      begin
        while xSeq.ReadNextChildNode(xRowNode) do
        begin
          _Navigate(xRowNode);
        end;
      end;

      xSeq.GoToPath('/');//go to end
    finally
      xSeq.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml Sequential DOM'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((Integer(xT3-xT2)-Integer(xT2-xT1)) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure TestOXmlDirect;
  var
    xReaderToken: PXMLReaderToken;
    xXmlReader: TXMLReader;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;

    xXmlReader := TXMLReader.Create;
    try
      xXmlReader.InitFile(DocDir+'sheet1.xml');
      while xXmlReader.ReadNextToken({%H-}xReaderToken) do begin
      end;
    finally
      xXmlReader.Free;
    end;

    xT2 := GetTickCount;

    xXmlReader := TXMLReader.Create;
    try
      xXmlReader.InitFile(DocDir+'sheet1.xml');
      while xXmlReader.ReadNextToken({%H-}xReaderToken) do begin
        DoNothing(xReaderToken.TokenName, xReaderToken.TokenValue);
      end;
    finally
      xXmlReader.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml direct reader'+sLineBreak+
      'Load: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Navigate: '+FloatToStr((Integer(xT3-xT2)-Integer(xT2-xT1)) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;


  {$IFDEF USE_DELPHIXML}
  TestDelphiXmlDOM(SMSXML);
  {$IFDEF USE_ADOM}
  TestDelphiXmlDOM(sAdom4XmlVendor);
  {$ENDIF}
  TestDelphiXmlDOM(sOXmlDOMVendor);
  {$ENDIF}

  {$IFDEF USE_MSXML}
  TestMSXmlDOM;
  {$ENDIF}

  {$IFDEF USE_OMNIXML}
  TestOmniXmlDOM;
  {$ENDIF}

  {$IFDEF USE_NATIVEXML}
  TestNativeXmlDOM;
  {$ENDIF}

  {$IFDEF USE_VERYSIMPLE}
  //TestVerySimpleXmlDOM;  <- ALWAYS FAILS!!!
  {$ENDIF}

  {$IFDEF USE_SIMPLEXML}
  TestSimpleXmlDOM;
  {$ENDIF}

  {$IFDEF USE_DIXML}
  TestDIXmlDOM;
  {$ENDIF}

  {$IFDEF USE_ALCINOE}
  TestAlcinoeDOM;
  TestAlcinoeSAX;
  {$ENDIF}

  {$IFDEF USE_LAZARUSDOMXML}
  TestLazarusDOM;

  TestLazarusSAX;
  {$ENDIF}

  TestOXmlCDOM;

  TestOXmlPDOM;

  TestOXmlSeq;

  TestOXmlSAX;

  TestOXmlDirect;
end;

procedure TForm1.BtnResaveTestClick(Sender: TObject);
  procedure TestOXmlPDOM;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xT1, xT2, xT3: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.WhiteSpaceHandling := wsPreserveAll;
    xXml.LoadFromFile(DocDir+'sheet1.xml');
    xT2 := GetTickCount;
    xXml.SaveToFile(DocDir+'sheet1-resave.xml');

    xXml := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml record DOM (default)'+sLineBreak+
      'Read: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Write: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure TestDirect;
  var
    xXmlReader: TXMLReader;
    xXmlWriter: TXMLWriter;
    xT1, xT2, xT3: Cardinal;
    xE: PXMLReaderToken;
  begin
    xT1 := GetTickCount;
    xXmlReader := nil;
    xXmlWriter := nil;
    try
      xXmlReader := TXMLReader.Create;
      xXmlWriter := TXMLWriter.Create;

      xXmlReader.InitFile(DocDir+'sheet1.xml');

      xXmlWriter.InitFile(DocDir+'sheet1-resave.xml');
      xXmlWriter.Encoding := TEncoding.UTF8;
      xXmlWriter.WriterSettings.WriteBOM := False;

      //simulate reading
      while xXmlReader.ReadNextToken({%H-}xE) do begin
        DoNothing(xE.TokenName, xE.TokenValue);
      end;
      xT2 := GetTickCount;

      //read+write
      xXmlReader.InitFile(DocDir+'sheet1.xml');
      xXmlWriter.XmlDeclaration(True);
      while xXmlReader.ReadNextToken(xE) do begin
        case xE.TokenType of
          rtAttribute: xXmlWriter.Attribute(xE.TokenName, xE.TokenValue);
          rtOpenElement: xXmlWriter.OpenElement(xE.TokenName);
          rtFinishOpenElement: xXmlWriter.FinishOpenElement;
          rtFinishOpenElementClose: xXmlWriter.FinishOpenElementClose;
          rtCloseElement: xXmlWriter.CloseElement(xE.TokenName);
          rtText: xXmlWriter.Text(xE.TokenValue);
          rtCData: xXmlWriter.CData(xE.TokenValue);
          rtComment: xXmlWriter.Comment(xE.TokenValue);
          rtProcessingInstruction: xXmlWriter.ProcessingInstruction(xE.TokenName, xE.TokenValue);
        end;
      end;
    finally
      xXmlReader.Free;
      xXmlWriter.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml direct reader/writer'+sLineBreak+
      'Read: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Write: '+FloatToStr((Integer(xT3-xT2)-Integer(xT2-xT1)) / 1000)+sLineBreak+
      'Whole: '+FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  procedure TestSAX;
  var
    xSAX: TSAXParser;
    xT1, xT2: Cardinal;
  begin
    xT1 := GetTickCount;

    xSAX := TSAXParser.Create;
    try
      xSAX.ParseFile(DocDir+'sheet1.xml');
    finally
      xSAX.Free;
    end;

    xT2 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml SAX'+sLineBreak+
      'Read: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure _MatchTestFiles;
  begin
    MatchTestFiles(DocDir+'sheet1.xml', DocDir+'sheet1-resave.xml');
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  TestOXmlPDOM;
  _MatchTestFiles;

  TestSAX;

  TestDirect;
  _MatchTestFiles;
end;

procedure TForm1.BtnSequentialTestClick(Sender: TObject);
  procedure TestSeq(const aXML, aCorrectOutput: OWideString; aMemo: TMemo);
  var
    xSeqParser: TXMLSeqParser;
    xNode, xAttr: OXmlPDOM.PXMLNode;
    xItemsElementIsOpen: Boolean;
    xName, xColor, xText: OWideString;
  begin
    xSeqParser := TXMLSeqParser.Create;
    try
      xSeqParser.InitXML(aXML);
      xSeqParser.ReaderSettings.BreakReading := brNone;

      if not xSeqParser.GoToPath('/root/items:test') then
        raise Exception.Create('Wrong XML document.');

      if not xSeqParser.ReadNextChildElementHeader({%H-}xNode, {%H-}xItemsElementIsOpen) then
        raise Exception.Create('Wrong XML document.');

      aMemo.Lines.Add(xNode.XML);

      aMemo.Lines.Add('-----');

      if xItemsElementIsOpen then begin
        while xSeqParser.ReadNextChildNode(xNode) do
        begin
          if (xNode.NodeType = ntElement) and
             (xNode.NodeName = 'item')
          then begin
            if xNode.FindAttribute('color', {%H-}xAttr) then
              xColor := xAttr.NodeValue
            else
              xColor := '[default]';
            xName := xNode.Attributes['name'];
            xText := xNode.Text;

            aMemo.Lines.Add(xNode.XML);
            aMemo.Lines.Add('  -> '+xName+':'+xColor+':'+xText);
          end;
        end;
      end;

      aMemo.Lines.Add('-----');

      while xSeqParser.ReadNextChildElementHeaderClose(xNode) do
      begin
        if (xNode.NodeType = ntElement) and
           (xNode.NodeName = 'info')
        then
          aMemo.Lines.Add(xNode.XML);
      end;

      aMemo.Lines.Add('-----');

      if xSeqParser.GoToPath('/root2') then
      if xSeqParser.SkipNextChildElementHeader(xItemsElementIsOpen) then
      if xItemsElementIsOpen then
      begin
        while xSeqParser.ReadNextChildNode(xNode) do
          aMemo.Lines.Add(xNode.XML);
      end;

      if aMemo.Lines.Text <> aCorrectOutput then
        raise Exception.Create('Sequential parser test failed');

    finally
      xSeqParser.Free;
    end;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  TestSeq(
    '<root>'+
      '<items:test defaultcolor="red">'+
        '<item />'+
        '<item name="car" color="blue" />'+
        '<skip>Skip this element</skip>'+
        '<item name="bike">bike has <b>default</b> color!</item>'+
        '<item name="tree" color="green" />'+
      '</items:test>'+
      '<info text="Yes, I want to know it!" />'+
      'skip texts'+
      '<info text="Show me!" />'+
      '<info />'+
    '</root>'+
    '<root2>'+
      'text'+
      '<items:test:2 defaultcolor="red" />'+
      '<items:test:2 defaultcolor="green" />'+
      '<items:test:2 />'+
      '<items:test:2 />'+
      'text'+
    '</root2>'+
    ''
    ,
      '<items:test defaultcolor="red"/>'+sLineBreak+
      '-----'+sLineBreak+
      '<item/>'+sLineBreak+
      '  -> :[default]:'+sLineBreak+
      '<item name="car" color="blue"/>'+sLineBreak+
      '  -> car:blue:'+sLineBreak+
      '<item name="bike">bike has <b>default</b> color!</item>'+sLineBreak+
      '  -> bike:[default]:bike has default color!'+sLineBreak+
      '<item name="tree" color="green"/>'+sLineBreak+
      '  -> tree:green:'+sLineBreak+
      '-----'+sLineBreak+
      '<info text="Yes, I want to know it!"/>'+sLineBreak+
      '<info text="Show me!"/>'+sLineBreak+
      '<info/>'+sLineBreak+
      '-----'+sLineBreak+
      'text'+sLineBreak+
      '<items:test:2 defaultcolor="red"/>'+sLineBreak+
      '<items:test:2 defaultcolor="green"/>'+sLineBreak+
      '<items:test:2/>'+sLineBreak+
      '<items:test:2/>'+sLineBreak+
      'text'+sLineBreak+
      ''
    ,
  Memo1);

  TestSeq(
    '<root>'+
      '<items:test defaultcolor="red" />'+
      'skip texts'+
      '<info text="Yes, I want to know it!">'+
        'skip this information'+
        '<skip>all elements in info tag are not read</skip>'+
      '</info>'+
      '<info text="Show me!" />'+
    '</root>'
    ,
      '<items:test defaultcolor="red"/>'+sLineBreak+
      '-----'+sLineBreak+
      '-----'+sLineBreak+
      '<info text="Yes, I want to know it!"/>'+sLineBreak+
      '<info text="Show me!"/>'+sLineBreak+
      '-----'+sLineBreak+
      ''
    ,
  Memo2);

end;

function SAXEscapeString(const aString: OWideString): OWideString;
begin
  Result := aString;
  Result := OStringReplace(Result, sLineBreak, '\n', [rfReplaceAll]);
  Result := OStringReplace(Result, '"', '\"', [rfReplaceAll]);
end;

procedure TForm1.BtnTestWriteInvalidClick(Sender: TObject);

  procedure TestOXmlPDOM;
  var
    xXML: OXmlPDOM.IXMLDocument;
    xRoot: OXmlPDOM.PXMLNode;
  begin
    xXML := OXmlPDOM.CreateXMLDoc('root');
    xXML.WriterSettings.StrictXML := False;//set to true/false - allow/disallow invalid document
    xXML.ReaderSettings.StrictXML := False;//set to true/false - allow/disallow invalid document

    //comment/uncomment to test validity
    xRoot := xXML.DocumentElement;
    xRoot.Attributes['0name'] := 'test';//invalid attribute name
    xRoot.AddChild('0name');//invalid name
    xRoot.AddComment('te--st');//invalid comment (a comment cannot contain "--" string
    xRoot.AddCDATASection('te]]>st');//invalid cdata (a cdata section cannot contain "]]>" string

    Memo1.Lines.Text := xXML.XML;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  TestOXmlPDOM;
end;

procedure TForm1.BtnTestReadInvalidClick(Sender: TObject);
const
  cXML: OWideString =
    '<root><kolo></root>'+sLineBreak+
    '  <item < AttributeWithoutValue attr2 = value2 attr3  =  "value3"  ? />'+sLineBreak+
    '  <![aaa'+sLineBreak+
    '  kolo >'+sLineBreak+
    '  <test />>'+sLineBreak+
    '  <!-x'+sLineBreak+
    '  <!'+sLineBreak+
    '  <!rr'+sLineBreak+
    '  <!DOC'+
    '  <<<'+sLineBreak+
    ' &nbsp ; '+sLineBreak+
    '  <lo.ko> <para> <b> TEXT </i> </lo.ko>'+
    '  <? = aaa ?>'+
    '  <?= aaa ?>'+
    '  <?aaa ?>'+
    '  <??>'+
    '</root>';

  procedure TestOXmlPDOM;
  var
    xXml: OXmlPDOM.IXMLDocument;
  begin
    xXML := OXmlPDOM.CreateXMLDoc;
    xXML.ReaderSettings.StrictXML := False;//set to true/false - allow/disallow invalid document
    xXML.ReaderSettings.BreakReading := brNone;
    xXML.WriterSettings.StrictXML := False;//set to true/false - allow/disallow invalid document

    xXML.WhiteSpaceHandling := wsPreserveAll;
    xXML.LoadFromXML(cXML);

    Memo2.Lines.Add('OXml record based DOM:');
    Memo2.Lines.Text := Memo2.Lines.Text + xXML.XML;
  end;
begin
  Memo1.Lines.Text :=
    'Original invalid XML:'+sLineBreak+sLineBreak+
    cXML;
  Memo2.Lines.Text :=
    'XML as it is read and understood by OXml:'+sLineBreak+sLineBreak;

  TestOXmlPDOM;
end;

procedure TForm1.BtnTestSAXClick(Sender: TObject);
var
  xSAX: TSAXParser;
const
  cXML: OWideString =
    '<?xml version="1.0"?>'+sLineBreak+
    '<seminararbeit>'+sLineBreak+
    ' <titel>DOM, SAX und SOAP</titel>'+sLineBreak+
    ' <inhalt>'+sLineBreak+
    '  <kapitel value="1">Einleitung</kapitel>'+sLineBreak+
    '  <kapitel value="2" attr="val">Hauptteil</kapitel>'+sLineBreak+
    '  <kapitel value="3">Fazit</kapitel>'+sLineBreak+
    '  <kapitel value="4" />'+sLineBreak+
    ' </inhalt>'+sLineBreak+
    ' <!-- comment -->'+sLineBreak+
    ' <![CDATA[ cdata ]]>'+sLineBreak+
    ' <?php echo "custom processing instruction" ?>'+sLineBreak+
    '</seminararbeit>'+sLineBreak;
begin
  Memo1.Lines.BeginUpdate;
  Memo2.Lines.BeginUpdate;

  xSAX := TSAXParser.Create;
  try
    Memo1.Lines.Clear;
    Memo2.Lines.Clear;

    {$IFNDEF USE_ANONYMOUS_METHODS}
    Memo1.Lines.Text := 'Events:'+sLineBreak+sLineBreak;

    //old-fashioned events
    xSAX.OnStartDocument := SAXStartDocument;
    xSAX.OnEndDocument := SAXEndDocument;
    xSAX.OnCharacters := SAXCharacters;
    xSAX.OnComment := SAXComment;
    xSAX.OnProcessingInstruction := SAXProcessingInstruction;
    xSAX.OnStartElement := SAXStartElement;
    xSAX.OnEndElement := SAXEndElement;
    {$ELSE}
    Memo1.Lines.Text := 'Anonymous methods:'+sLineBreak+sLineBreak;

    //anonymous methods
    xSAX.OnStartDocument := (
      procedure(aSaxParser: TSAXParser)
      begin
        Memo1.Lines.Add('startDocument()');
      end);

    xSAX.OnEndDocument := (
      procedure(aSaxParser: TSAXParser)
      begin
        Memo1.Lines.Add('endDocument()');
      end);

    xSAX.OnCharacters := (
      procedure(aSaxParser: TSAXParser; const aText: OWideString)
      begin
        Memo1.Lines.Add('characters("'+SAXEscapeString(aText)+'")');
      end);

    xSAX.OnComment := (
      procedure(aSaxParser: TSAXParser; const aText: OWideString)
      begin
        Memo1.Lines.Add('comment("'+SAXEscapeString(aText)+'")');
      end);

    xSAX.OnProcessingInstruction := (
      procedure(aSaxParser: TSAXParser; const aTarget, aContent: OWideString)
      begin
        Memo1.Lines.Add('processingInstruction("'+SAXEscapeString(aTarget)+'", "'+SAXEscapeString(aContent)+'")');
      end);

    xSAX.OnStartElement := (
      procedure(aSaxParser: TSAXParser; const aName: OWideString;
        const aAttributes: TSAXAttributes)
      var
        xAttrStr: OWideString;
        xAttr: PSAXAttribute;
      begin
        xAttrStr := '';
        for xAttr in aAttributes do begin
          if xAttrStr <> '' then
            xAttrStr := xAttrStr + ', ';
          xAttrStr := xAttrStr + SAXEscapeString(xAttr.TokenName)+'="'+SAXEscapeString(xAttr.TokenValue)+'"';
        end;
        xAttrStr := '['+xAttrStr+']';

        Memo1.Lines.Add('startElement("'+SAXEscapeString(aName)+'", '+xAttrStr+')');
      end);

    xSAX.OnEndElement := (
      procedure(aSaxParser: TSAXParser; const aName: OWideString)
      begin
        Memo1.Lines.Add('endElement("'+SAXEscapeString(aName)+'")');
      end);
    {$ENDIF}

    xSAX.ParseXML(cXML);
  finally
    xSAX.Free;

    Memo1.Lines.EndUpdate;
    Memo2.Lines.EndUpdate;
  end;
end;

procedure TForm1.BtnTestXPathClick(Sender: TObject);
const
  cXML: OWideString =
    //'  '+sLineBreak+'  '+
    '<?xml version="1.0" encoding="utf-8" ?>'+
    '<root description="test xml">'+
      '<boss name="Max Muster">'+
        '<person name="boss person"/>'+
        '<person name="boss person 2">'+
          '<person name="boss person/2.1"/>'+
          '<dog name="boss dog 2.2" type="fight" />'+
        '</person>'+
      '</boss>'+
      '<!-- comment -->'+
      '<person name="Paul Caster">this text is in person tag</person>'+
      '<![CDATA[some test info]]>'+
      '<?pi processing instruction ?>'+
    '</root>';

  {$IFDEF USE_OMNIXML}
  procedure TestOmniXML;
  var
    xXml: OmniXML.IXMLDocument;

    procedure _TestXPathElements(const aStartNode: OmniXML.IXMLNode; const aXPath, aResult: OWideString);
    var
      xList: OmniXML.IXMLNodeList;
      xElement: OmniXML.IXMLNode;
      xAttr: OmniXML.IXMLNode;
      xStr: OWideString;
      I: Integer;
    begin
      aStartNode.SelectNodes(aXPath, {%H-}xList);
      if xList.Length > 0 then begin
        xStr := '';
        for I := 0 to xList.Length-1 do begin
          xElement := xList.Item[I];

          if xStr <> '' then
            xStr := xStr+sLineBreak;
          case xElement.NodeType of
            ELEMENT_NODE: begin
              xStr := xStr+xElement.NodeName+'=';
              xAttr := xElement.Attributes.GetNamedItem('name');
              if Assigned(xAttr) then
                xStr := xStr+xAttr.NodeValue;
            end;
            ATTRIBUTE_NODE: xStr := xStr+xElement.ParentNode.NodeName+':'+xElement.NodeName+'='+xElement.NodeValue;
            TEXT_NODE, CDATA_SECTION_NODE: xStr := xStr+xElement.NodeValue;
          end;
        end;

        if xStr <> aResult then begin
          Memo1.Lines.Text := (
            'XPath test failed: '+aXPath+sLineBreak+
              xStr+sLineBreak+
              '-----'+sLineBreak+
              aResult);
          raise Exception.Create(Form1.Memo1.Lines.Text);
        end;
      end else begin
        raise Exception.Create('XPath test failed (nothing selected): '+aXPath);
      end;
    end;
  begin
    xXml := OmniXML.CreateXMLDoc;

    xXml.LoadXML(cXML);

    _TestXPathElements(xXml.DocumentElement, '.', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/.', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/boss/..', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/person', 'person=Paul Caster');
    //not supported by OmniXML:_TestXPathElements(xXml.DocumentElement, '..//person[@name="boss person/2.1"]', 'person=boss person/2.1');
    //not supported by OmniXML:_TestXPathElements(xXml.DocumentElement, '//person[@name="boss person/2.1"]', 'person=boss person/2.1');
    //not supported by OmniXML:_TestXPathElements(xXml, '//person[@name]', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, '//root//person/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    //OmniXML: ERROR _TestXPathElements(xXml, '//person/../../boss', 'boss=Max Muster');
    _TestXPathElements(xXml, '//person', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, 'root//person', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, 'root//boss/person', 'person=boss person'+sLineBreak+'person=boss person 2');
    _TestXPathElements(xXml, 'root//*', 'boss=Max Muster'+sLineBreak+'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, 'root/*', 'boss=Max Muster'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, '/root/boss/person', 'person=boss person'+sLineBreak+'person=boss person 2');
    _TestXPathElements(xXml, 'root/boss', 'boss=Max Muster');
    //not supported by OmniXML:_TestXPathElements(xXml, 'root/person|root/boss', 'boss=Max Muster'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, 'root', 'root=');
    _TestXPathElements(xXml, 'root/boss/person[2]/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    _TestXPathElements(xXml, 'root/person[1]', 'person=Paul Caster');
    //not supported by OmniXML:_TestXPathElements(xXml, 'root/person[last()]', 'person=Paul Caster');
    //not supported by OmniXML:_TestXPathElements(xXml, '/root/*[last()-1]/person[last()]/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    //not supported by OmniXML:_TestXPathElements(xXml, '//text()', 'this text is in person tag'+sLineBreak+'some test info');
    //not supported by OmniXML:_TestXPathElements(xXml, 'root/node()', 'root:description=test xml'+sLineBreak+'boss=Max Muster'+sLineBreak+'person=Paul Caster'+sLineBreak+'some test info');

    //not supported by OmniXML:_TestXPathElements(xXml, 'root//@*', 'root:description=test xml'+sLineBreak+'boss:name=Max Muster'+sLineBreak+'person:name=boss person'+sLineBreak+'person:name=boss person 2'+sLineBreak+'person:name=boss person/2.1'+sLineBreak+'dog:name=boss dog 2.2'+sLineBreak+'dog:type=fight'+sLineBreak+'person:name=Paul Caster');
    //not supported by OmniXML:_TestXPathElements(xXml, 'root//@name', 'boss:name=Max Muster'+sLineBreak+'person:name=boss person'+sLineBreak+'person:name=boss person 2'+sLineBreak+'person:name=boss person/2.1'+sLineBreak+'dog:name=boss dog 2.2'+sLineBreak+'person:name=Paul Caster');

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OmniXML DOM: All XPath tests succeeded.';
  end;
  {$ENDIF}

  procedure TestOXmlPDOM;
  var
    xXml: OXmlPDOM.IXMLDocument;

    procedure _TestXPathElements(const aStartNode: OXmlPDOM.PXMLNode; const aXPath, aResult: OWideString);
    var
      xList: OXmlPDOM.IXMLNodeList;
      xElement: OXmlPDOM.PXMLNode;
      xStr: OWideString;
      {$IFNDEF USE_FORIN}
      I: Integer;
      {$ENDIF}
    begin
      if aStartNode.SelectNodes(aXPath, {%H-}xList) then begin
        xStr := '';
        {$IFDEF USE_FORIN}
        for xElement in xList do begin
        {$ELSE}
        for I := 0 to xList.Count-1 do begin
          xElement := xList[I];
        {$ENDIF}
          if xStr <> '' then
          if xStr <> '' then
            xStr := xStr+sLineBreak;
          case xElement.NodeType of
            ntElement: xStr := xStr+xElement.NodeName+'='+xElement.Attributes['name'];
            ntAttribute: xStr := xStr+xElement.ParentNode.NodeName+':'+xElement.NodeName+'='+xElement.NodeValue;
            ntText, ntCData: xStr := xStr+xElement.NodeValue;
          end;
        end;

        if xStr <> aResult then begin
          Memo1.Lines.Text := (
            'XPath test failed: '+aXPath+sLineBreak+
              xStr+sLineBreak+
              '-----'+sLineBreak+
              aResult);
          raise Exception.Create(Memo1.Lines.Text);
        end;
      end else begin
        raise Exception.Create('XPath test failed (nothing selected): '+aXPath);
      end;
    end;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    _TestXPathElements(xXml.DocumentElement, '.', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root|../root', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/.', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/boss/..', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/person', 'person=Paul Caster');
    _TestXPathElements(xXml.DocumentElement, '..//person[@name="boss person/2.1"]', 'person=boss person/2.1');
    _TestXPathElements(xXml.DocumentElement, '//person[@name="boss person/2.1"]', 'person=boss person/2.1');
    _TestXPathElements(xXml.Node, '//person[@name]', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, '//root//person/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    _TestXPathElements(xXml.Node, '//person/../../boss', 'boss=Max Muster');
    _TestXPathElements(xXml.Node, '//person', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, 'root//person', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, 'root//boss/person', 'person=boss person'+sLineBreak+'person=boss person 2');
    _TestXPathElements(xXml.Node, 'root//*', 'boss=Max Muster'+sLineBreak+'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, 'root/*', 'boss=Max Muster'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, '/root/boss/person', 'person=boss person'+sLineBreak+'person=boss person 2');
    _TestXPathElements(xXml.Node, 'root/boss', 'boss=Max Muster');
    _TestXPathElements(xXml.Node, 'root/person|root/boss', 'boss=Max Muster'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, 'root', 'root=');
    _TestXPathElements(xXml.Node, 'root/boss/person[2]/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    _TestXPathElements(xXml.Node, 'root/person[1]', 'person=Paul Caster');
    _TestXPathElements(xXml.Node, 'root/person[last()]', 'person=Paul Caster');
    _TestXPathElements(xXml.Node, '/root/*[last()-1]/person[last()]/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    _TestXPathElements(xXml.Node, '//text()', 'this text is in person tag'+sLineBreak+'some test info');
    _TestXPathElements(xXml.Node, 'root/node()', 'root:description=test xml'+sLineBreak+'boss=Max Muster'+sLineBreak+'person=Paul Caster'+sLineBreak+'some test info');


    _TestXPathElements(xXml.Node, 'root//@*', 'root:description=test xml'+sLineBreak+'boss:name=Max Muster'+sLineBreak+'person:name=boss person'+sLineBreak+'person:name=boss person 2'+sLineBreak+'person:name=boss person/2.1'+sLineBreak+'dog:name=boss dog 2.2'+sLineBreak+'dog:type=fight'+sLineBreak+'person:name=Paul Caster');
    _TestXPathElements(xXml.Node, 'root//@name', 'boss:name=Max Muster'+sLineBreak+'person:name=boss person'+sLineBreak+'person:name=boss person 2'+sLineBreak+'person:name=boss person/2.1'+sLineBreak+'dog:name=boss dog 2.2'+sLineBreak+'person:name=Paul Caster');

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml record DOM: All XPath tests succeeded.';
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  {$IFDEF USE_OMNIXML}
  TestOmniXML;
  {$ENDIF}

  TestOXmlPDOM;
end;

procedure TForm1.BtnIterateTestClick(Sender: TObject);
const
  cXML: OWideString =
    '<root attr1="z" attr2="o" attr3="3x" attr4="y4">'+
      '<element1>Hello</element1>'+
      '<element2>Bye</element2>'+
      '<element3/>'+
    '</root>';

  {$IFDEF USE_FORIN}
  procedure TestOXmlPDOMForIn;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    for xNode in xXML.DocumentElement.ChildNodes do
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.Text);

    Memo1.Lines.Add('');
  end;
  {$ENDIF}

  procedure TestOXmlPDOMForTo;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
    I: Integer;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    for I := 0 to xRoot.ChildNodes.Count-1 do begin
      xNode := xRoot.ChildNodes[I];
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.Text);
    end;

    Memo1.Lines.Add('');
  end;

  procedure TestOXmlPDOMForDownTo;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
    I: Integer;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    for I := xRoot.ChildNodes.Count-1 downto 0 do begin
      xNode := xRoot.ChildNodes[I];
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.Text);
    end;

    Memo1.Lines.Add('');
  end;

  procedure TestOXmlPDOMNextChild;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    xNode := nil;
    while xRoot.GetNextChild(xNode) do
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.Text);

    Memo1.Lines.Add('');
  end;

  procedure TestOXmlPDOMPreviousChild;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    xNode := nil;
    while xRoot.GetPreviousChild(xNode) do
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.Text);

    Memo1.Lines.Add('');
  end;

  procedure TestOXmlPDOMNextSibling;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xNode := xXML.DocumentElement.FirstChild;
    while Assigned(xNode) do begin
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.Text);
      xNode := xNode.NextSibling;
    end;

    Memo1.Lines.Add('');
  end;

  procedure TestOXmlPDOMPreviousSibling;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xNode := xXML.DocumentElement.LastChild;
    while Assigned(xNode) do begin
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.Text);
      xNode := xNode.PreviousSibling;
    end;

    Memo1.Lines.Add('');
  end;

  {$IFDEF USE_FORIN}
  procedure TestOXmlPDOMAttributesForIn;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    for xNode in xXML.DocumentElement.AttributeNodes do
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.NodeValue);

    Memo1.Lines.Add('');
  end;
  {$ENDIF}

  procedure TestOXmlPDOMAttributesForTo;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
    I: Integer;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    for I := 0 to xRoot.AttributeNodes.Count-1 do begin
      xNode := xRoot.AttributeNodes[I];
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.NodeValue);
    end;

    Memo1.Lines.Add('');
  end;

  procedure TestOXmlPDOMAttributesForDownTo;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
    I: Integer;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    for I := xRoot.AttributeNodes.Count-1 downto 0 do begin
      xNode := xRoot.AttributeNodes[I];
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.NodeValue);
    end;

    Memo1.Lines.Add('');
  end;

  procedure TestOXmlPDOMNextAttribute;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    xNode := nil;
    while xRoot.GetNextAttribute(xNode) do
      Memo1.Lines.Add(xNode.NodeName+': '+xNode.NodeValue);

    Memo1.Lines.Add('');
  end;

begin
  Memo1.Lines.BeginUpdate;
  Memo2.Lines.BeginUpdate;
  try
    Memo1.Lines.Clear;
    Memo2.Lines.Clear;

    {$IFDEF USE_FORIN}
    TestOXmlPDOMForIn;
    {$ENDIF}
    TestOXmlPDOMForTo;
    TestOXmlPDOMForDownTo;
    TestOXmlPDOMNextChild;
    TestOXmlPDOMNextSibling;
    TestOXmlPDOMPreviousChild;
    TestOXmlPDOMPreviousSibling;
    {$IFDEF USE_FORIN}
    TestOXmlPDOMAttributesForIn;
    {$ENDIF}
    TestOXmlPDOMAttributesForTo;
    TestOXmlPDOMAttributesForDownTo;
    TestOXmlPDOMNextAttribute;

  finally
    Memo1.Lines.EndUpdate;
    Memo2.Lines.EndUpdate;
  end;
end;

procedure TForm1.BtnAttributeTestClick(Sender: TObject);
var
  xXML: OXmlPDOM.IXMLDocument;
  xRoot: OXmlPDOM.PXMLNode;
  I: Integer;
  xT1, xT2, xT3: Cardinal;
const
  cAttrCount = 100*1000;// << play around
begin
  {
    About this test:
    Because OXmlPDOM doesn't use indexed attribute list, somebody may think that
    the GetAttribute(aName) function should be slow. This example code tests
    this issue.

    As you can see, a lot of unique attributes of the same element are created
    (exactly cAttrCount). Then all of those attributes are retrieved back from
    the XML document.

    The limit of "pretty good" performance (= "no time needed") is somewhere
    around 1'000 attributes, which is reasonable as 1000*(1000+1)/2 ~= 500'000
    cycles are needed to go through all attributes, which is nothing for
    an 1 GHz PC.

    The limit of "acceptable" performance is about 10'000 attributes. Above
    this limit, the performance is getting from "bad" to "fail".

    To my mind, this performance is absolutely OK - have you ever seen an XML
    document with more than 100 attributes in one element?

    (Creating an indexed list for every element would be much slower overall!)
  }

  xXML := OXmlPDOM.CreateXMLDoc('root');
  xRoot := xXML.DocumentElement;

  xT1 := GetTickCount;
  for I := 1 to cAttrCount do
    xRoot.AddAttribute(IntToStr(I), '');

  xT2 := GetTickCount;
  for I := 1 to cAttrCount do
    xRoot.GetAttribute(IntToStr(I));

  xT3 := GetTickCount;

  Memo1.Lines.Text :=
    'Attribute performance test"'+sLineBreak+
    'Attribute count: '+IntToStr(cAttrCount)+sLineBreak+
    'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
    'Get: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak;
  Memo2.Lines.Clear;
end;

procedure TForm1.BtnDOMTestClick(Sender: TObject);
  procedure TestOXmlPDOM;
  var
    xXML: OXmlPDOM.IXMLDocument;
    xRoot: OXmlPDOM.PXMLNode;
    xChild1, xChild2, xChild3, xChild4, xReplacedChild: OXmlPDOM.PXMLNode;
    xAttribute: OXmlPDOM.PXMLNode;
  begin
    xXML := OXmlPDOM.CreateXMLDoc('root');

    xRoot := xXML.DocumentElement;

    xChild1 := xXML.CreateElement('test');
    xRoot.AppendChild(xChild1);

    xAttribute := xXML.CreateAttribute('attr', 'value');
    xChild1.SetAttributeNode(xAttribute);

    xChild2 := xXML.CreateElement('child2');
    xRoot.InsertBefore(xChild2, xChild1);

    xChild3 := xXML.CreateElement('node3');
    xReplacedChild := xRoot.ReplaceChild(xChild3, xChild2);
    if Assigned(xReplacedChild) then//the replaced child doesn't get destroyed automatically
      xReplacedChild.DeleteSelf;//free the old child

    xChild4 := xXML.CreateElement('child4');
    xRoot.InsertBefore(xChild4, xRoot.FirstChild);

    Memo1.Lines.Text := xXML.XML;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  TestOXmlPDOM;
end;

procedure TForm1.BtnEncodingTestClick(Sender: TObject);
  procedure TestOXmlPDOM;
  var
    xXML: OXmlPDOM.IXMLDocument;
  begin
    xXML := OXmlPDOM.CreateXMLDoc;

    xXML.LoadFromFile(DocDir+'koi8-r.xml');
    xXML.DocumentElement.SelectNode('load').LoadFromXML('some <i>text</i> with <b>tags</b>');
    xXML.CodePage := CP_WIN_1251;
    xXML.SaveToFile(DocDir+'1251.xml');

    xXML.WriterSettings.IndentType := itIndent;
    Memo1.Lines.Text := xXML.XML;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  TestOXmlPDOM;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Memo1.SetBounds(0, LblTimeInfo.BoundsRect.Bottom + 5, ClientWidth div 2, ClientHeight-LblTimeInfo.BoundsRect.Bottom - 5);
  Memo2.SetBounds(Memo1.BoundsRect.Right, Memo1.BoundsRect.Top, ClientWidth-Memo1.BoundsRect.Right, Memo1.Height);
end;

procedure TForm1.MatchTestFiles(const aFileSource, aFileTarget: OWideString);
var
  xReader1, xReader2: TOTextReader;
  xBuffer1, xBuffer2: TOTextBuffer;
  xC1, xC2: OWideChar;
  I: Integer;
begin
  xC1 := #0;
  xC2 := #0;
  xReader1 := TOTextReader.Create;
  xReader2 := TOTextReader.Create;
  xBuffer1 := TOTextBuffer.Create;
  xBuffer2 := TOTextBuffer.Create;
  try
    xReader1.InitFile(aFileSource);
    xReader2.InitFile(aFileTarget);

    //start comparing after PI
    while (xC1 <> '>') do
      if not xReader1.ReadNextChar(xC1) then
        Break;
    while xC2 <> '>' do
      if not xReader2.ReadNextChar(xC2) then
        Break;
    xReader1.ReadNextChar(xC1);
    xReader2.ReadNextChar(xC2);
    while OXmlIsWhiteSpaceChar(xC1) do
      if not xReader1.ReadNextChar(xC1) then
        Break;
    while OXmlIsWhiteSpaceChar(xC2) do
      if not xReader2.ReadNextChar(xC2) then
        Break;

    while True do begin
      if not xReader1.ReadNextChar(xC1) then
        break;
      xReader2.ReadNextChar(xC2);
      if xC1 <> xC2 then begin
        //get some information
        xBuffer1.Clear;
        xBuffer2.Clear;
        xBuffer1.WriteChar(xC1);
        xBuffer2.WriteChar(xC2);
        for I := 0 to 19 do begin
          if not xReader1.ReadNextChar(xC1) then
            Break;
          if not xReader2.ReadNextChar(xC2) then
            Break;
          xBuffer1.WriteChar(xC1);
          xBuffer2.WriteChar(xC2);
        end;

        raise Exception.Create('Files do not match:'+sLineBreak+
          'Reader1 = '+xBuffer1.GetBuffer+sLineBreak+
          'Reader2 = '+xBuffer2.GetBuffer+sLineBreak);
      end;

      if xC2 = #0 then
        Break;
    end;
  finally
    xReader1.Free;
    xReader2.Free;
    xBuffer1.Free;
    xBuffer2.Free;
  end;
end;

{$IFDEF USE_ALCINOE}
procedure TForm1.Navigate_AlcinoeSAXStartElement(Sender: TObject; const Path,
  Name: AnsiString; const Attributes: TALStrings);
var
  I: Integer;
begin
  DoNothing({$IFNDEF FPC}{$IFDEF UNICODE}UTF8ToString{$ELSE}UTF8Decode{$ENDIF}{$ENDIF}(Name), '');

  if Assigned(Attributes) then
  for I := 0 to Attributes.Count-1 do
    DoNothing(
      {$IFNDEF FPC}{$IFDEF UNICODE}UTF8ToString{$ELSE}UTF8Decode{$ENDIF}{$ENDIF}(Attributes.Names[I]),
      {$IFNDEF FPC}{$IFDEF UNICODE}UTF8ToString{$ELSE}UTF8Decode{$ENDIF}{$ENDIF}(Attributes.ValueFromIndex[I]));
end;
{$ENDIF}

procedure TForm1.Navigate_SAXEndElement(Sender: TSAXParser;
  const aName: OWideString);
begin
  //do nothing
end;

{$IFDEF USE_LAZARUSDOMXML}
procedure TForm1.Navigate_LazarusSAXStartElement(Sender: TObject;
  const NamespaceURI, LocalName, QName: SAXString; Atts: SAX.TSAXAttributes);
var
  I: Integer;
begin
  DoNothing(LocalName, '');

  if Assigned(Atts) then
  for I := 0 to Atts.Length-1 do
    DoNothing(Atts.GetLocalName(I), Atts.GetValue(I));
end;

procedure TForm1.Navigate_LazarusSAXEndElement(Sender: TObject;
  const NamespaceURI, LocalName, QName: SAXString);
begin
  //do nothing
end;
{$ENDIF}

procedure TForm1.Navigate_SAXStartElement(Sender: TSAXParser;
  const aName: OWideString; const aAttributes: TSAXAttributes);
var
  I: Integer;
begin
  DoNothing(aName, '');

  for I := 0 to aAttributes.Count-1 do
    DoNothing(aAttributes[I].TokenName, aAttributes[I].TokenValue);
end;

procedure TForm1.BtnWritePerformanceTestClick(Sender: TObject);
  {$IFDEF USE_DELPHIXML}
  procedure DelphiXmlTest(const aVendorName: String; const aFullExport: Boolean);
  var
    I, xLimit: Integer;
    xT1, xT2, xT3: Cardinal;
    xXML: XMLDoc.TXMLDocument;
    xXMLIntf: XmlIntf.IXMLDocument;
    xRootNode, xNode: XmlIntf.IXMLNode;
  begin
    xT1 := GetTickCount;

    xXML := XMLDoc.TXMLDocument.Create(nil);
    xXMLIntf := xXml;

    xXML.DOMVendor := xmldom.GetDOMVendor(aVendorName);
    xXML.Active := True;
    xXML.Encoding := 'utf-8';
    xXML.DocumentElement := xXML.CreateElement('root', '');
    xRootNode := xXML.DocumentElement;

    if aFullExport then
      xLimit := 100*1000
    else
      xLimit := 10*1000;

    for I := 1 to xLimit do begin
      xNode := xRootNode.AddChild('text');
      xNode.AddChild('A'+IntToStr(I)).AddChild('noname').AddChild('some').AddChild('p').Text := 'afg';
      xNode.SetAttribute('attr1', 'A'+IntToStr(I));
      xNode.SetAttribute('attr2', 'const');
      xNode.SetAttribute('attr3', 'const');
    end;

    xT2 := GetTickCount;

    xXML.SaveToFile(DocDir+'domtest-created.xml');

    xRootNode := nil;
    xNode := nil;
    xXMLIntf := nil;


    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'DELPHI XML with "'+aVendorName+'" vendor'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak;
    if not aFullExport then
      Memo1.Lines.Text :=
        Memo1.Lines.Text+
        'IMPORTANT: The Delphi XML with '+aVendorName+' vendor performance is so horrible'+sLineBreak+
        'that it''s not possible to create the nodes within a reasonable'+sLineBreak+
        'time limit. Therefore only 1/10 of the nodes are created!'+sLineBreak;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_MSXML}
  procedure MSXmlTest;
  var
    I: Integer;
    xT1, xT2, xT3: Cardinal;
    xXML: msxml.IXMLDOMDocument;
    xRootNode, xNode, xNewChild, xFirstNode: msxml.IXMLDOMNode;
    xNewAttr: msxml.IXMLDOMAttribute;
  begin
    xT1 := GetTickCount;

    xXML := msxmldom.CreateDOMDocument;
    xXML.appendChild(xXML.createProcessingInstruction('xml', 'version="1.0" encoding="utf-8"'));
    xRootNode := xXML.createElement('root');
    xXML.appendChild(xRootNode);
    for I := 1 to 100*1000 do begin
      xNewChild := xXML.CreateElement('text');
      xNode := xRootNode.AppendChild(xNewChild);
      xFirstNode := xNode;

      xNewChild := xXML.CreateElement('A'+IntToStr(I));
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateElement('noname');
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateElement('some');
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateElement('p');
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateTextNode('afg');
      xNode := xNode.AppendChild(xNewChild);

      xNewAttr := xXML.CreateAttribute('attr1');
      xNewAttr.Value := 'A'+IntToStr(I);
      xFirstNode.Attributes.setNamedItem(xNewAttr);
      xNewAttr := xXML.CreateAttribute('attr2');
      xNewAttr.Value := 'const';
      xFirstNode.Attributes.setNamedItem(xNewAttr);
      xNewAttr := xXML.CreateAttribute('attr3');
      xNewAttr.Value := 'const';
      xFirstNode.Attributes.setNamedItem(xNewAttr);
    end;

    xT2 := GetTickCount;

    xXML.save(DocDir+'domtest-created.xml');

    xRootNode := nil;
    xNode := nil;
    xXML := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'MS XML DOM'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_OMNIXML}
  procedure OmniXmlTest;
  var
    I: Integer;
    xT1, xT2, xT3: Cardinal;
    xXML: OmniXml.IXMLDocument;
    xRootNode, xNode, xNewChild, xFirstNode: OmniXml.IXMLNode;
    xNewAttr: OmniXml.IXMLAttr;
  begin
    xT1 := GetTickCount;

    xXML := OmniXml.CreateXMLDoc;
    xXML.AppendChild(xXML.createProcessingInstruction('xml', 'encoding="utf-8"'));
    xXML.DocumentElement := xXML.CreateElement('root');
    xRootNode := xXML.DocumentElement;
    for I := 1 to 100*1000 do begin
      xNewChild := xXML.CreateElement('text');
      xNode := xRootNode.AppendChild(xNewChild);
      xFirstNode := xNode;

      xNewChild := xXML.CreateElement('A'+IntToStr(I));
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateElement('noname');
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateElement('some');
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateElement('p');
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateTextNode('afg');
      xNode := xNode.AppendChild(xNewChild);

      xNewAttr := xXML.CreateAttribute('attr1');
      xNewAttr.Value := 'A'+IntToStr(I);
      xFirstNode.Attributes.Add(xNewAttr);
      xNewAttr := xXML.CreateAttribute('attr2');
      xNewAttr.Value := 'const';
      xFirstNode.Attributes.Add(xNewAttr);
      xNewAttr := xXML.CreateAttribute('attr3');
      xNewAttr.Value := 'const';
      xFirstNode.Attributes.Add(xNewAttr);
    end;

    xT2 := GetTickCount;

    xXML.Save(DocDir+'domtest-created.xml');

    xRootNode := nil;
    xNode := nil;
    xXML := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OmniXML DOM'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_NATIVEXML}
  procedure NativeXmlTest;
  var
    I: Integer;
    xT1, xT2, xT3: Cardinal;
    xXML: NativeXml.TNativeXml;
    xRootNode, xNode, xNodeN: NativeXml.TXmlNode;
  begin
    xT1 := GetTickCount;

    xXML := NativeXml.TNativeXml.CreateEx(nil, True, False, True, 'root');
    try
      xRootNode := xXML.Root;
      for I := 1 to 100*1000 do begin
        xNode := xXML.NodeNew('text');
        xRootNode.NodeAdd(xNode);

        xNode.AttributeAdd('attr1', {$IFNDEF FPC}UTF8Encode{$ENDIF}('A'+IntToStr(I)));
        xNode.AttributeAdd('attr2', 'const');
        xNode.AttributeAdd('attr3', 'const');

        xNodeN := xXML.NodeNew({$IFNDEF FPC}UTF8Encode{$ENDIF}('A'+IntToStr(I)));
        xNode.NodeAdd(xNodeN);
        xNode := xNodeN;

        xNodeN := xXML.NodeNew('noname');
        xNode.NodeAdd(xNodeN);
        xNode := xNodeN;

        xNodeN := xXML.NodeNew('some');
        xNode.NodeAdd(xNodeN);
        xNode := xNodeN;

        xNodeN := xXML.NodeNew('p');
        xNode.NodeAdd(xNodeN);
        xNode := xNodeN;

        xNodeN := xXML.NodeNewTextType('', 'afg', xeCharData);
        xNode.NodeAdd(xNodeN);
      end;

      xT2 := GetTickCount;

      xXML.SaveToFile(DocDir+'domtest-created.xml');

    finally
      xXML.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'NativeXml DOM'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_VERYSIMPLE}
  procedure VerySimpleXmlTest;
  var
    xXML: Xml.VerySimple.TXmlVerySimple;
    I: Integer;
    xT1, xT2, xT3: Cardinal;
    xRootNode, xNode: Xml.VerySimple.TXMLNode;
  begin
    xT1 := GetTickCount;

    xXML := Xml.VerySimple.TXmlVerySimple.Create;
    try
      xXML.Root.NodeName := 'root';
      xRootNode := xXML.Root;
      for I := 1 to 100*1000 do begin
        xNode := xRootNode.AddChild('text');
        xNode.AddChild('A'+IntToStr(I)).AddChild('noname').AddChild('some').AddChild('p').Text := 'afg';
        xNode.SetAttribute('attr1', 'A'+IntToStr(I));
        xNode.SetAttribute('attr2', 'const');
        xNode.SetAttribute('attr3', 'const');
      end;

      xT2 := GetTickCount;

      xXML.SaveToFile(DocDir+'domtest-created.xml');
    finally
      xXML.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'VerySimpleXML DOM'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_SIMPLEXML}
  procedure SimpleXmlTest;
  var
    xXML: SimpleXML.IXmlDocument;
    I: Integer;
    xT1, xT2, xT3: Cardinal;
    xRootNode, xNode, xNewChild, xFirstNode: SimpleXML.IXMLNode;
  begin
    xT1 := GetTickCount;

    xXML := SimpleXML.CreateXmlDocument('root', '1.0', 'utf-8');

    xRootNode := xXML.DocumentElement;
    for I := 1 to 100*1000 do begin
      xNode := xXML.CreateElement('text');
      xRootNode.AppendChild(xNode);
      xFirstNode := xNode;

      xNewChild := xXML.CreateElement('A'+IntToStr(I));
      xNode.AppendChild(xNewChild);
      xNode := xNewChild;

      xNewChild := xXML.CreateElement('noname');
      xNode.AppendChild(xNewChild);
      xNode := xNewChild;

      xNewChild := xXML.CreateElement('some');
      xNode.AppendChild(xNewChild);
      xNode := xNewChild;

      xNewChild := xXML.CreateElement('p');
      xNode.AppendChild(xNewChild);
      xNode := xNewChild;

      xNewChild := xXML.CreateText('afg');
      xNode.AppendChild(xNewChild);
      xNode := xNewChild;

      xFirstNode.SetAttr('attr1', 'A'+IntToStr(I));
      xFirstNode.SetAttr('attr2', 'const');
      xFirstNode.SetAttr('attr3', 'const');
    end;

    xT2 := GetTickCount;

    xXML.Save(DocDir+'domtest-created.xml');

    xRootNode := nil;
    xNode := nil;
    xFirstNode := nil;
    xXML := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'SimpleXML DOM'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_DIXML}
  procedure DIXmlTest;
  var
    xXML: DIXml.xmlDocPtr;
    I: Integer;
    xT1, xT2, xT3: Cardinal;
    xRootNode, xNode, xFirstNode: DIXml.xmlNodePtr;
  begin
    xT1 := GetTickCount;

    DIXml.xmlInitParser;

    xXML := DIXml.xmlNewDoc('1.0');
    xRootNode := xmlNewNode(nil, 'root');
    xmlDocSetRootElement(xXML, xRootNode);

    for I := 1 to 100*1000 do begin
      xNode := DIXml.xmlNewChild(xRootNode, nil, 'text', '');
      xFirstNode := xNode;

      xNode := DIXml.xmlNewChild(xNode, nil, PAnsiChar({$IFNDEF FPC}UTF8Encode{$ENDIF}('A'+IntToStr(I))), '');

      xNode := DIXml.xmlNewChild(xNode, nil, 'noname', '');

      xNode := DIXml.xmlNewChild(xNode, nil, 'some', '');

      DIXml.xmlNewTextChild(xNode, nil, 'p', 'afg');

      xmlNewProp(xFirstNode, 'attr1', PAnsiChar({$IFNDEF FPC}UTF8Encode{$ENDIF}('A'+IntToStr(I))));
      xmlNewProp(xFirstNode, 'attr2', 'const');
      xmlNewProp(xFirstNode, 'attr3', 'const');
    end;

    xT2 := GetTickCount;

    DIXml.xmlSaveFormatFileEnc(PAnsiChar({$IFNDEF FPC}UTF8Encode{$ENDIF}(DocDir+'domtest-created.xml')), xXML, 'utf-8', 0);

    DIXml.xmlFreeDoc(xXML);
    DIXml.xmlCleanupParser;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'DIXml DOM'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_LAZARUSDOMXML}
  procedure LazarusDOMTest;
  var
    I: Integer;
    xT1, xT2, xT3: Cardinal;
    xXML: DOM.TXMLDocument;
    xRootNode, xNode, xNewChild, xFirstNode: DOM.TDOMNode;
    xNewAttr: DOM.TDOMAttr;
  begin
    xT1 := GetTickCount;

    xXML := DOM.TXMLDocument.Create;
    try
      xXML.AppendChild(xXML.CreateElement('root'));
      xRootNode := xXML.DocumentElement;
      for I := 1 to 100*1000 do begin
        xNewChild := xXML.CreateElement('text');
        xNode := xRootNode.AppendChild(xNewChild);
        xFirstNode := xNode;

        xNewChild := xXML.CreateElement('A'+IntToStr(I));
        xNode := xNode.AppendChild(xNewChild);

        xNewChild := xXML.CreateElement('noname');
        xNode := xNode.AppendChild(xNewChild);

        xNewChild := xXML.CreateElement('some');
        xNode := xNode.AppendChild(xNewChild);

        xNewChild := xXML.CreateElement('p');
        xNode := xNode.AppendChild(xNewChild);

        xNewChild := xXML.CreateTextNode('afg');
        xNode := xNode.AppendChild(xNewChild);

        xNewAttr := xXML.CreateAttribute('attr1');
        xNewAttr.Value := 'A'+IntToStr(I);
        xFirstNode.Attributes.SetNamedItem(xNewAttr);
        xNewAttr := xXML.CreateAttribute('attr2');
        xNewAttr.Value := 'const';
        xFirstNode.Attributes.SetNamedItem(xNewAttr);
        xNewAttr := xXML.CreateAttribute('attr3');
        xNewAttr.Value := 'const';
        xFirstNode.Attributes.SetNamedItem(xNewAttr);
      end;

      xT2 := GetTickCount;

      XMLWrite.WriteXMLFile(xXML, DocDir+'domtest-created.xml');
    finally
      xXML.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'Lazarus DOM'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_ALCINOE}
  procedure AlcinoeXmlTest;
  var
    I: Integer;
    xT1, xT2, xT3: Cardinal;
    xXML: AlXmlDoc.TALXMLDocument;
    xRootNode, xNode: AlXmlDoc.TALXMLNode;
  begin
    xT1 := GetTickCount;

    xXML := AlXmlDoc.TALXMLDocument.Create();
    try
      xXML.Active := True;
      xXML.Encoding := 'utf-8';
      xXML.DocumentElement := xXML.CreateElement('root');
      xRootNode := xXML.DocumentElement;

      for I := 1 to 100*1000 do begin
        xNode := xRootNode.AddChild('text');
        xNode.AddChild('A'+IntToStr(I)).AddChild('noname').AddChild('some').AddChild('p').Text := 'afg';
        xNode.Attributes['attr1'] := 'A'+IntToStr(I);
        xNode.Attributes['attr2'] := 'const';
        xNode.Attributes['attr3'] := 'const';
      end;

      xT2 := GetTickCount;

      xXML.SaveToFile(DocDir+'domtest-created.xml');

      xRootNode := nil;
      xNode := nil;
    finally
      xXML.Free;
    end;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'Alcinoe XML'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  procedure OXmlCDOMTest;
  var
    xXML: OXmlCDOM.IXMLDocument;
    I: Integer;
    xT1, xT2, xT3: Cardinal;
    xRootNode, xNode: OXmlCDOM.TXMLNode;
  begin
    xT1 := GetTickCount;

    xXML := OXmlCDOM.CreateXMLDoc('root', True);
    xXML.WhiteSpaceHandling := wsTrim;
    xXML.WriterSettings.WriteBOM := False;
    xRootNode := xXML.DocumentElement;
    for I := 1 to 100*1000 do begin
      xNode := xRootNode.AddChild('text');
      xNode.AddChild('A'+IntToStr(I)).AddChild('noname').AddChild('some').AddChild('p').AddText('afg');
      xNode.AddAttribute('attr1', 'A'+IntToStr(I));
      xNode.AddAttribute('attr2', 'const');
      xNode.AddAttribute('attr3', 'const');
    end;

    xT2 := GetTickCount;

    xXML.SaveToFile(DocDir+'domtest-created.xml');

    xXML := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml class DOM'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure OXmlPDOMTest;
  var
    xXML: OXmlPDOM.IXMLDocument;
    I: Integer;
    xT1, xT2, xT3: Cardinal;
    xRootNode, xNode: OXmlPDOM.PXMLNode;
  begin
    xT1 := GetTickCount;

    xXML := OXmlPDOM.CreateXMLDoc('root', True);
    xXML.WhiteSpaceHandling := wsTrim;
    xXML.WriterSettings.WriteBOM := False;
    xRootNode := xXML.DocumentElement;
    for I := 1 to 100*1000 do begin
      xNode := xRootNode.AddChild('text');
      xNode.AddChild('A'+IntToStr(I)).AddChild('noname').AddChild('some').AddChild('p').AddText('afg');
      xNode.AddAttribute('attr1', 'A'+IntToStr(I));
      xNode.AddAttribute('attr2', 'const');
      xNode.AddAttribute('attr3', 'const');
    end;

    xT2 := GetTickCount;

    xXML.SaveToFile(DocDir+'domtest-created.xml');

    xXML := nil;

    xT3 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml record DOM'+sLineBreak+
      'Create: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Save: ' + FloatToStr((xT3-xT2) / 1000)+sLineBreak+
      'Whole: ' + FloatToStr((xT3-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure OXmlDirectTest;
  var
    xXML: TXMLWriter;
    xT1, xT2: Cardinal;
    I: Integer;
    xElementA, xElementNoname, xElementSome, xElementP, xElementRoot, xElementText: TXMLWriterElement;
  begin
    xT1 := GetTickCount;

    xXML := TXMLWriter.Create;
    try
      xXML.InitFile(DocDir+'domtest-created.xml');
      xXML.WriterSettings.WriteBOM := False;

      xXML.XMLDeclaration(True, '1.0', 'yes');

      xXML.OpenElementR('root', {%H-}xElementRoot);
      for I := 1 to 100*1000 do begin
        xElementRoot.OpenElementR('text', {%H-}xElementText);
        xElementText.Attribute('attr1', 'A'+IntToStr(I));
        xElementText.Attribute('attr2', 'const');
        xElementText.Attribute('attr3', 'const');

        xElementText.OpenElementR('A'+IntToStr(I), {%H-}xElementA);
        xElementA.OpenElementR('noname', {%H-}xElementNoname);
        xElementNoname.OpenElementR('some', {%H-}xElementSome);
        xElementSome.OpenElementR('p', {%H-}xElementP);
        xElementP.Text('afg');
        xElementP.CloseElement;
        xElementSome.CloseElement;
        xElementNoname.CloseElement;
        xElementA.CloseElement;
        xElementText.CloseElement;
      end;
      xElementRoot.CloseElement;
    finally
      xXML.Free;
    end;

    xT2 := GetTickCount;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml direct writer'+sLineBreak+
      'Save: ' + FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure _MatchTestFiles;
  begin
    MatchTestFiles(DocDir+'domtest.xml', DocDir+'domtest-created.xml');
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  {$IFDEF USE_DELPHIXML}
  DelphiXmlTest(SMSXML, False);
  //_MatchTestFiles; <- do not test on matching DelphiXmlTest, only 1/10 nodes were created!
  {$IFDEF USE_ADOM}
  DelphiXmlTest(sAdom4XmlVendor, True);
  _MatchTestFiles;
  {$ENDIF}
  DelphiXmlTest(sOXmlDOMVendor, True);
  _MatchTestFiles;
  {$ENDIF}
  {$IFDEF USE_MSXML}
  MSXmlTest;
  _MatchTestFiles;
  {$ENDIF}
  {$IFDEF USE_OMNIXML}
  OmniXmlTest;
  _MatchTestFiles;
  {$ENDIF}
  {$IFDEF USE_NATIVEXML}
  NativeXmlTest;
  _MatchTestFiles;
  {$ENDIF}
  {$IFDEF USE_VERYSIMPLE}
  VerySimpleXmlTest;
  //_MatchTestFiles; <- do not test on matching VerySimpleXmlTest
  {$ENDIF}
  {$IFDEF USE_SIMPLEXML}
  SimpleXmlTest;
  //_MatchTestFiles; <- do not test on matching SimpleXmlTest
  {$ENDIF}
  {$IFDEF USE_DIXML}
  DIXmlTest;
  _MatchTestFiles;
  {$ENDIF}
  {$IFDEF USE_LAZARUSDOMXML}
  LazarusDOMTest;
  //_MatchTestFiles; <- do not test on matching LazarusDOMTest
  {$ENDIF}
  {$IFDEF USE_ALCINOE}
  AlcinoeXmlTest;
  _MatchTestFiles;
  {$ENDIF}

  OXmlCDOMTest;
  _MatchTestFiles;

  OXmlPDOMTest;
  _MatchTestFiles;

  OXmlDirectTest;
  _MatchTestFiles;
end;

procedure TForm1.BtnXmlDirectWriteClick(Sender: TObject);
  procedure WriteDocument;
  var
    xS: TStream;
    xXmlWriter: TXMLWriter;
    xRootElement, xPersonElement: TXMLWriterElement;
  begin
    xS := TFileStream.Create(DocDir+'simple.xml', fmCreate);
    xXmlWriter := TXMLWriter.Create;
    try
      xXmlWriter.InitStream(xS);
      xXmlWriter.Encoding := TEncoding.UTF8;
      xXmlWriter.WriterSettings.IndentType := itNone;

      xXmlWriter.DocType('root PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"');
      xXmlWriter.XmlDeclaration(True);

      xRootElement := xXmlWriter.OpenElementR('root');
      xRootElement.Attribute('description', 'test xml');

      xPersonElement := xRootElement.OpenElementR('boss');
      xPersonElement.Attribute('name', '?Max Muster');
      xPersonElement.CloseElement;

      xRootElement.Comment('this is some text in comment');

      xPersonElement := xRootElement.OpenElementR('person');
      xPersonElement.Attribute('name', '/Paul Caster');
      xPersonElement.Text('/this text is in person tag');
      xPersonElement.CloseElement;

      xRootElement.Text('some test info');

      xRootElement.CData('!this is some text in <CDATA> section.');
      xRootElement.ProcessingInstruction('target', '((custom processing instruction.))');

      xRootElement.CloseElement;
    finally
      xXmlWriter.Free;
      xS.Free;
    end;
  end;

  procedure TestOXmlPDOM;
  var
    xXml: OXmlPDOM.IXMLDocument;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.WhiteSpaceHandling := wsPreserveAll;
    xXml.LoadFromFile(DocDir+'simple.xml');
    xXML.WriterSettings.IndentType := itIndent;
    Memo1.Lines.Text :=
      xXml.XML+sLineBreak+sLineBreak+
      '------'+sLineBreak+
      xXml.DocumentElement.Text;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  //WRITE DOCUMENT
  WriteDocument;

  //READ DOCUMENT AND FORMAT IT NICELY
  TestOXmlPDOM;
end;

procedure TForm1.DoCreate;
begin
  inherited;

  DocDir := ExtractFilePath(Application.ExeName)+'..'+PathDelim+'doc'+PathDelim;

  {$IFNDEF FPC}{$IF CompilerVersion >= 18}//Delphi 2006 UP
  ReportMemoryLeaksOnShutdown := True;
  {$IFEND}{$ENDIF}
end;

{$IFNDEF USE_ANONYMOUS_METHODS}
procedure TForm1.SAXCharacters(Sender: TSAXParser; const aText: OWideString);
begin
  Memo1.Lines.Add('characters("'+SAXEscapeString(aText)+'")');
end;

procedure TForm1.SAXComment(Sender: TSAXParser; const aText: OWideString);
begin
  Memo1.Lines.Add('comment("'+SAXEscapeString(aText)+'")');
end;

procedure TForm1.SAXEndDocument(Sender: TSAXParser);
begin
  Memo1.Lines.Add('endDocument()');
end;

procedure TForm1.SAXEndElement(Sender: TSAXParser; const aName: OWideString);
begin
  Memo1.Lines.Add('endElement("'+SAXEscapeString(aName)+'")');
end;

procedure TForm1.SAXProcessingInstruction(Sender: TSAXParser; const aTarget,
  aContent: OWideString);
begin
  Memo1.Lines.Add('processingInstruction("'+SAXEscapeString(aTarget)+'", "'+SAXEscapeString(aContent)+'")');
end;

procedure TForm1.SAXStartDocument(Sender: TSAXParser);
begin
  Memo1.Lines.Add('startDocument()');
end;

procedure TForm1.SAXStartElement(Sender: TSAXParser; const aName: OWideString;
  const aAttributes: TSAXAttributes);
var
  xAttrStr: OWideString;
  xAttr: PSAXAttribute;
  {$IFNDEF USE_FORIN}
  I: Integer;
  {$ENDIF}
begin
  xAttrStr := '';
  {$IFDEF USE_FORIN}
  for xAttr in aAttributes do
  begin
  {$ELSE}
  for I := 0 to aAttributes.Count-1 do
  begin
    xAttr := aAttributes[I];
  {$ENDIF}
    if xAttrStr <> '' then
      xAttrStr := xAttrStr + ', ';
    xAttrStr := xAttrStr + SAXEscapeString(xAttr.TokenName)+'="'+SAXEscapeString(xAttr.TokenValue)+'"';
  end;
  xAttrStr := '['+xAttrStr+']';

  Memo1.Lines.Add('startElement("'+SAXEscapeString(aName)+'", '+xAttrStr+')');
end;
{$ENDIF}

procedure TForm1.DoNothing(const aStr1, aStr2: OWideString);
begin
  //nothing
end;

end.

