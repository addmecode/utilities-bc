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
        TimeVal: Time;
        UnsupportedFieldTypeErr: Label 'Unsupported field type %1 in field: (%2).', Comment = '%1 = Field type, %2 = Field name';
        InvalidFieldValueErr: Label 'Cannot evaluate value %1 for field: (%2).', Comment = '%1 = Field value, %2 = Field name';
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
}
