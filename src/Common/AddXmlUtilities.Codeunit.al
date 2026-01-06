codeunit 50149 "Add Xml Utilities"
{
    /// <summary>
    /// Reads an XML document from a stream and prepares a namespace manager.
    /// </summary>
    /// <param name="ImportedXlfInStream">Input stream with the XML content.</param>
    /// <param name="NamespacePrefix">Prefix to register for the namespace.</param>
    /// <param name="XmlDocument">XML document output.</param>
    /// <param name="NamespaceManager">Namespace manager output.</param>
    procedure GetXmlDocumentAndNamespaceManagerFromInStream(ImportedXlfInStream: InStream; NamespacePrefix: Text; var XmlDoc: XmlDocument; var NamespaceManager: XmlNamespaceManager)
    var
        NamespaceUri: Text;
        RootElement: XmlElement;
    begin
        XmlDocument.ReadFrom(ImportedXlfInStream, XmlDoc);
        XmlDoc.GetRoot(RootElement);
        NamespaceUri := RootElement.NamespaceUri();
        NamespaceManager.AddNamespace(NamespacePrefix, NamespaceUri);
    end;

    /// <summary>
    /// Gets an attribute value by name from an attribute collection.
    /// </summary>
    /// <param name="AttributeCollection">Attribute collection to search.</param>
    /// <param name="AttributeName">Attribute name.</param>
    /// <returns>The attribute value.</returns>
    procedure GetAttributeValueFromCollection(AttributeCollection: XmlAttributeCollection; AttributeName: Text): Text
    var
        Attribute: XmlAttribute;
    begin
        AttributeCollection.Get(AttributeName, Attribute);
        exit(Attribute.Value());
    end;

    /// <summary>
    /// Gets a named attribute from a node.
    /// </summary>
    /// <param name="ElementAttribute">Output attribute.</param>
    /// <param name="AttributeName">Attribute name to get.</param>
    /// <param name="ElementNode">XML node with attributes.</param>
    procedure GetElementAttribute(var ElementAttribute: XmlAttribute; AttributeName: Text; ElementNode: XmlNode)
    var
        ElementAttributes: XmlAttributeCollection;
    begin
        ElementAttributes := ElementNode.AsXmlElement().Attributes();
        ElementAttributes.Get(AttributeName, ElementAttribute);
    end;

    /// <summary>
    /// Creates a new line node for XML formatting.
    /// </summary>
    /// <param name="NewLineNode">Output node with newline text.</param>
    procedure CreateNewLineNode(var NewLineNode: XmlNode)
    var
        TypeHelper: Codeunit "Type Helper";
        NewLineText: Text;
    begin
        NewLineText := TypeHelper.CRLFSeparator() + '          ';
        NewLineNode := XmlText.Create(NewLineText).AsXmlNode();
    end;

    /// <summary>
    /// Downloads an XML document to a file.
    /// </summary>
    /// <param name="XmlDocument">Document to download.</param>
    /// <param name="DownloadToFileName">Target file name.</param>
    procedure DownloadXmlDocument(XmlDocument: XmlDocument; DownloadToFileName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        XmlDocument.WriteTo(OutStream);
        TempBlob.CreateInStream(InStream);
        DownloadFromStream(InStream, '', '', '', DownloadToFileName);
    end;
}
