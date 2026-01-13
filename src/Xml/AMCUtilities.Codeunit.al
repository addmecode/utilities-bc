codeunit 50148 "AMC Utilities"
{
    /// <summary>
    /// Calculates the batch size based on total rows and update percentage.
    /// </summary>
    /// <param name="TotalRowsNumber">Total number of rows to process.</param>
    /// <param name="ProgressUpdatePercent">Progress update percentage.</param>
    /// <returns>The rounded batch size.</returns>
    procedure GetUpdateProgressBatch(TotalRowsNumber: Integer; ProgressUpdatePercent: Decimal): Integer
    begin
        exit(Round(TotalRowsNumber * ProgressUpdatePercent, 1, '>'));
    end;

    local procedure ValidateFieldFromText(var FieldReference: FieldRef; FieldValue: Text)
    var
        EvaluatedValue: Variant;
    begin
        this.EvaluateFieldValueFromText(FieldReference, FieldValue, EvaluatedValue);
        FieldReference.Validate(EvaluatedValue);
    end;

    local procedure SetFieldFromText(var FieldReference: FieldRef; FieldValue: Text)
    var
        EvaluatedValue: Variant;
    begin
        this.EvaluateFieldValueFromText(FieldReference, FieldValue, EvaluatedValue);
        FieldReference.Value := EvaluatedValue;
    end;

    local procedure EvaluateFieldValueFromText(FieldReference: FieldRef; FieldValue: Text; var EvaluatedValue: Variant)
    var
        DateFormulaValue: DateFormula;
        BigIntegerValue: BigInteger;
        BooleanValue: Boolean;
        DateValue: Date;
        DateTimeValue: DateTime;
        DecimalValue: Decimal;
        DurationValue: Duration;
        GuidValue: Guid;
        IntegerValue: Integer;
        InvalidFieldValueErr: Label 'Cannot evaluate value %1 for field: (%2).', Comment = '%1 = Field value, %2 = Field name';
        UnsupportedFieldTypeErr: Label 'Unsupported field type %1 in field: (%2).', Comment = '%1 = Field type, %2 = Field name';
        TimeValue: Time;
    begin
        case FieldReference.Type of
            FieldReference.Type::Boolean:
                begin
                    if not Evaluate(BooleanValue, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FieldReference.Name);
                    EvaluatedValue := BooleanValue;
                end;
            FieldReference.Type::Integer:
                begin
                    if not Evaluate(IntegerValue, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FieldReference.Name);
                    EvaluatedValue := IntegerValue;
                end;
            FieldReference.Type::BigInteger:
                begin
                    if not Evaluate(BigIntegerValue, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FieldReference.Name);
                    EvaluatedValue := BigIntegerValue;
                end;
            FieldReference.Type::Decimal:
                begin
                    if not Evaluate(DecimalValue, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FieldReference.Name);
                    EvaluatedValue := DecimalValue;
                end;
            FieldReference.Type::Date:
                begin
                    if not Evaluate(DateValue, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FieldReference.Name);
                    EvaluatedValue := DateValue;
                end;
            FieldReference.Type::DateTime:
                begin
                    if not Evaluate(DateTimeValue, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FieldReference.Name);
                    EvaluatedValue := DateTimeValue;
                end;
            FieldReference.Type::Time:
                begin
                    if not Evaluate(TimeValue, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FieldReference.Name);
                    EvaluatedValue := TimeValue;
                end;
            FieldReference.Type::Duration:
                begin
                    if not Evaluate(DurationValue, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FieldReference.Name);
                    EvaluatedValue := DurationValue;
                end;
            FieldReference.Type::Guid:
                begin
                    if not Evaluate(GuidValue, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FieldReference.Name);
                    EvaluatedValue := GuidValue;
                end;
            FieldReference.Type::DateFormula:
                begin
                    if not Evaluate(DateFormulaValue, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FieldReference.Name);
                    EvaluatedValue := DateFormulaValue;
                end;
            FieldReference.Type::Text, FieldReference.Type::Code:
                EvaluatedValue := FieldValue;
            else
                Error(UnsupportedFieldTypeErr, Format(FieldReference.Type), FieldReference.Name);
        end;
    end;

    /// <summary>
    /// Checks whether a report uses a request page.
    /// </summary>
    /// <param name="ReportId">Report object ID.</param>
    /// <returns>True if the report uses a request page; otherwise, false.</returns>
    procedure DoesReportHaveRequestPage(ReportId: Integer): Boolean
    var
        ReportMetadata: Record "Report Metadata";
    begin
        ReportMetadata.SetLoadFields(UseRequestPage);
        if not ReportMetadata.Get(ReportId) then
            exit(false);
        exit(ReportMetadata.UseRequestPage);
    end;

    /// <summary>
    /// Runs the specified application object with optional confirmation.
    /// </summary>
    /// <param name="ObjectToRun">Object metadata record.</param>
    /// <param name="HideDialog">True to suppress confirmations.</param>
    procedure RunObject(ObjectToRun: Record AllObjWithCaption; HideDialog: Boolean)
    begin
        case ObjectToRun."Object Type" of
            ObjectToRun."Object Type"::Page:
                this.RunPage(ObjectToRun."Object ID", HideDialog);
            ObjectToRun."Object Type"::Report:
                this.RunReport(ObjectToRun."Object ID", HideDialog);
            ObjectToRun."Object Type"::Codeunit:
                this.RunCodeunit(ObjectToRun."Object ID", HideDialog);
            ObjectToRun."Object Type"::Table:
                this.RunTable(ObjectToRun."Object ID", HideDialog);
        end;
    end;

    /// <summary>
    /// Runs a page after optional confirmation.
    /// </summary>
    /// <param name="PageId">Page object ID.</param>
    /// <param name="HideDialog">True to suppress confirmations.</param>
    procedure RunPage(PageId: Integer; HideDialog: Boolean)
    var
        ObjectTypePageLbl: Label 'Page', Locked = true;
    begin
        if not this.ConfirmRunObject(PageId, ObjectTypePageLbl, HideDialog) then
            exit;
        this.DoRunPage(PageId);
    end;

    local procedure DoRunPage(PageId: Integer)
    begin
        Page.Run(PageId);
    end;

    /// <summary>
    /// Runs a codeunit after optional confirmation.
    /// </summary>
    /// <param name="CodeunitId">Codeunit object ID.</param>
    /// <param name="HideDialog">True to suppress confirmations.</param>
    procedure RunCodeunit(CodeunitId: Integer; HideDialog: Boolean)
    var
        ObjectTypeCodeunitLbl: Label 'Codeunit', Locked = true;
    begin
        if not this.ConfirmRunObject(CodeunitId, ObjectTypeCodeunitLbl, HideDialog) then
            exit;
        this.DoRunCodeunit(CodeunitId);
    end;

    local procedure ConfirmRunObject(ObjectId: Integer; ObjectTypeCaption: Text; HideDialog: Boolean): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        DefaultAnswer: Boolean;
        ConfirmRunObjectLbl: Label 'Run %1 %2?', Comment = '%1 = Object type, %2 = Object ID';
    begin
        DefaultAnswer := true;
        if HideDialog then
            exit(DefaultAnswer);

        exit(ConfirmManagement.GetResponseOrDefault(
          StrSubstNo(ConfirmRunObjectLbl, ObjectTypeCaption, ObjectId),
          DefaultAnswer));
    end;

    local procedure DoRunCodeunit(CodeunitId: Integer)
    begin
        Codeunit.Run(CodeunitId);
    end;

    /// <summary>
    /// Runs a report after optional confirmation.
    /// </summary>
    /// <param name="ReportId">Report object ID.</param>
    /// <param name="HideDialog">True to suppress confirmations and the request page.</param>
    procedure RunReport(ReportId: Integer; HideDialog: Boolean)
    var
        ObjectTypeReportLbl: Label 'Report', Locked = true;
    begin
        if not this.ConfirmRunObject(ReportId, ObjectTypeReportLbl, HideDialog) then
            exit;

        this.DoRunReport(ReportId);
    end;

    local procedure DoRunReport(ReportId: Integer)
    begin
        Report.Run(ReportId);
    end;

    /// <summary>
    /// Runs a table by opening its list page or link.
    /// </summary>
    /// <param name="TableId">Table object ID.</param>
    /// <param name="HideDialog">True to suppress confirmations.</param>
    procedure RunTable(TableId: Integer; HideDialog: Boolean)
    var
        ObjectTypeTableLbl: Label 'Table', Locked = true;
    begin
        if not this.ConfirmRunObject(TableId, ObjectTypeTableLbl, HideDialog) then
            exit;

        this.DoRunTable(TableId);
    end;

    local procedure DoRunTable(TableId: Integer)
    var
        PageManagement: Codeunit "Page Management";
        RecRef: RecordRef;
        PageId: Integer;
    begin
        RecRef.Open(TableId);
        PageId := PageManagement.GetListPageID(RecRef);
        if PageId = 0 then begin
            this.RunTableLink(TableId);
            exit;
        end;

        Page.Run(PageId);
    end;

    local procedure RunTableLink(TableId: Integer)
    var
        TableUrl: Text;
    begin
        TableUrl := GetUrl(ClientType::Current, CompanyName, ObjectType::Table, TableId);
        if TableUrl = '' then
            exit;

        Hyperlink(TableUrl);
    end;
}
