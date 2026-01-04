codeunit 50141 "ADD_Utilities"
{
    procedure GetUpdProgrBatch(TotalRowsNumber: Integer; ProgrUpdPerc: Decimal): Integer
    begin
        exit(Round(TotalRowsNumber * ProgrUpdPerc, 1, '>'));
    end;

    local procedure ValidateFieldFromText(var FldRef: FieldRef; FieldValue: Text)
    var
        EvaluatedValue: Variant;
    begin
        this.EvaluateFieldValueFromText(FldRef, FieldValue, EvaluatedValue);
        FldRef.Validate(EvaluatedValue);
    end;

    local procedure SetFieldFromText(var FldRef: FieldRef; FieldValue: Text)
    var
        EvaluatedValue: Variant;
    begin
        this.EvaluateFieldValueFromText(FldRef, FieldValue, EvaluatedValue);
        FldRef.Value := EvaluatedValue;
    end;

    local procedure EvaluateFieldValueFromText(FldRef: FieldRef; FieldValue: Text; var EvaluatedValue: Variant)
    var
        DateFormulaVal: DateFormula;
        BigIntVal: BigInteger;
        BoolVal: Boolean;
        DateVal: Date;
        DateTimeVal: DateTime;
        DecVal: Decimal;
        DurVal: Duration;
        GuidVal: Guid;
        IntVal: Integer;
        InvalidFieldValueErr: Label 'Cannot evaluate value %1 for field: (%2).', Comment = '%1 = Field value, %2 = Field name';
        UnsupportedFieldTypeErr: Label 'Unsupported field type %1 in field: (%2).', Comment = '%1 = Field type, %2 = Field name';
        TimeVal: Time;
    begin
        case FldRef.Type of
            FldRef.Type::Boolean:
                begin
                    if not Evaluate(BoolVal, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FldRef.Name);
                    EvaluatedValue := BoolVal;
                end;
            FldRef.Type::Integer:
                begin
                    if not Evaluate(IntVal, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FldRef.Name);
                    EvaluatedValue := IntVal;
                end;
            FldRef.Type::BigInteger:
                begin
                    if not Evaluate(BigIntVal, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FldRef.Name);
                    EvaluatedValue := BigIntVal;
                end;
            FldRef.Type::Decimal:
                begin
                    if not Evaluate(DecVal, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FldRef.Name);
                    EvaluatedValue := DecVal;
                end;
            FldRef.Type::Date:
                begin
                    if not Evaluate(DateVal, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FldRef.Name);
                    EvaluatedValue := DateVal;
                end;
            FldRef.Type::DateTime:
                begin
                    if not Evaluate(DateTimeVal, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FldRef.Name);
                    EvaluatedValue := DateTimeVal;
                end;
            FldRef.Type::Time:
                begin
                    if not Evaluate(TimeVal, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FldRef.Name);
                    EvaluatedValue := TimeVal;
                end;
            FldRef.Type::Duration:
                begin
                    if not Evaluate(DurVal, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FldRef.Name);
                    EvaluatedValue := DurVal;
                end;
            FldRef.Type::Guid:
                begin
                    if not Evaluate(GuidVal, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FldRef.Name);
                    EvaluatedValue := GuidVal;
                end;
            FldRef.Type::DateFormula:
                begin
                    if not Evaluate(DateFormulaVal, FieldValue) then
                        Error(InvalidFieldValueErr, FieldValue, FldRef.Name);
                    EvaluatedValue := DateFormulaVal;
                end;
            FldRef.Type::Text, FldRef.Type::Code:
                EvaluatedValue := FieldValue;
            else
                Error(UnsupportedFieldTypeErr, Format(FldRef.Type), FldRef.Name);
        end;
    end;

    procedure DoesReportHaveReqPage(ReportId: Integer): Boolean
    var
        ReportMetadata: Record "Report Metadata";
    begin
        if not ReportMetadata.Get(ReportId) then
            exit(false);
        exit(ReportMetadata.UseRequestPage);
    end;

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

    procedure RunPage(PageId: Integer; HideDialog: Boolean)
    begin
        if not this.ConfirmRunObj(PageId, 'Codeunit', HideDialog) then
            exit;
        this.DoRunPage(PageId);
    end;

    local procedure DoRunPage(PageId: Integer)
    begin
        Page.Run(PageId)
    end;

    procedure RunCodeunit(CodeunitId: Integer; HideDialog: Boolean)
    begin
        if not this.ConfirmRunObj(CodeunitId, 'Codeunit', HideDialog) then
            exit;
        this.DoRunCodeunit(CodeunitId);
    end;

    local procedure ConfirmRunObj(ObjId: Integer; ObjType: Text; HideDialog: Boolean): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        DefaultAnswer: Boolean;
        ConfirmRunCodeunitLbl: Label 'Run %1 %2?', Comment = '%1 = Object Type, %2 = Object ID';
    begin
        DefaultAnswer := true;
        if HideDialog then
            exit(DefaultAnswer);

        exit(ConfirmManagement.GetResponseOrDefault(StrSubstNo(ConfirmRunCodeunitLbl, ObjType, ObjId), DefaultAnswer));
    end;

    local procedure DoRunCodeunit(CodeunitId: Integer)
    begin
        Codeunit.Run(CodeunitId);
    end;

    procedure RunReport(ReportId: Integer; HideDialog: Boolean)
    begin
        if not this.ConfirmRunObj(ReportId, 'Report', HideDialog) then
            exit;

        this.DoRunReport(ReportId);
    end;

    local procedure DoRunReport(ReportId: Integer)
    begin
        Report.Run(ReportId);
    end;

    procedure RunTable(TableId: Integer; HideDialog: Boolean)
    begin
        if not this.ConfirmRunObj(TableId, 'Table', HideDialog) then
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
