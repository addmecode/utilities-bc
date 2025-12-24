codeunit 50140 "ADD_XmlUtilities"
{
    procedure GetXmlDocAndNsMgrFromInStr(ImportedXlfInStr: InStream; NsPrefix: Text; var XmlDoc: XmlDocument; var NsMgr: XmlNamespaceManager)
    var
        NsUri: Text;
        Root: XmlElement;
    begin
        XmlDocument.ReadFrom(ImportedXlfInStr, XmlDoc);
        XmlDoc.GetRoot(Root);
        NsUri := Root.NamespaceUri();
        NsMgr.AddNamespace(NsPrefix, NsUri);
    end;

    procedure GetAttrValueFromCollection(AttrColl: XmlAttributeCollection; AttrName: Text): Text
    var
        Attr: XmlAttribute;
    begin
        AttrColl.Get(AttrName, Attr);
        exit(Attr.Value());
    end;

    procedure GetUpdProgrBatch(TotalRowsNumber: Integer; ProgrUpdPerc: Decimal): Integer
    begin
        exit(Round(TotalRowsNumber * ProgrUpdPerc, 1, '>'));
    end;

    procedure GetElementAttribute(var NoteAttr: XmlAttribute; AttributeName: Text; NoteNode: XmlNode)
    var
        NoteAttributes: XmlAttributeCollection;
    begin
        NoteAttributes := NoteNode.AsXmlElement().Attributes();
        NoteAttributes.Get(AttributeName, NoteAttr);
    end;

    procedure CreateNewLineNode(var NewLineNode: XmlNode)
    var
        TypeHelper: Codeunit "Type Helper";
        NewLineText: Text;
    begin
        NewLineText := TypeHelper.CRLFSeparator() + '          ';
        NewLineNode := XmlText.Create(NewLineText).AsXmlNode();
    end;

    procedure DownloadXmlDoc(XmlDoc: XmlDocument; DownloadToFileName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        XmlDoc.WriteTo(OutStr);
        TempBlob.CreateInStream(InStr);
        DownloadFromStream(InStr, '', '', '', DownloadToFileName);
    end;
}
