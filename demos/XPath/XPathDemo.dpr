program XPathDemo;

uses
  Forms,
  XPathDemo1 in 'XPathDemo1.pas' {frmXPathDemo},
  OBufferedStreams in '..\..\units\OBufferedStreams.pas',
  ODictionary in '..\..\units\ODictionary.pas',
  OEncoding in '..\..\units\OEncoding.pas',
  OHashedStrings in '..\..\units\OHashedStrings.pas',
  OTextReadWrite in '..\..\units\OTextReadWrite.pas',
  OWideSupp in '..\..\units\OWideSupp.pas',
  OXmlIntfDOM in '..\..\units\OXmlIntfDOM.pas',
  OXmlLng in '..\..\units\OXmlLng.pas',
  OXmlPDOM in '..\..\units\OXmlPDOM.pas',
  OXmlReadWrite in '..\..\units\OXmlReadWrite.pas',
  OXmlSAX in '..\..\units\OXmlSAX.pas',
  OXmlSeq in '..\..\units\OXmlSeq.pas',
  OXmlUtils in '..\..\units\OXmlUtils.pas',
  OXmlXPath in '..\..\units\OXmlXPath.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmXPathDemo, frmXPathDemo);
  Application.Run;
end.
