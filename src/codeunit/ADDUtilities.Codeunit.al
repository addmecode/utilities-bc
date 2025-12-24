codeunit 50141 "ADD_Utilities"
{
    procedure GetUpdProgrBatch(TotalRowsNumber: Integer; ProgrUpdPerc: Decimal): Integer
    begin
        exit(Round(TotalRowsNumber * ProgrUpdPerc, 1, '>'));
    end;

    local procedure ValidateFieldFromText(var FldRef: FieldRef; FieldValue: Text)
    var
        DateFormulaVal: DateFormula;
        BigIntVal: BigInteger;
        BoolVal: Boolean;
        TextVal: Text;
        DateVal: Date;
        DateTimeVal: DateTime;
        DecVal: Decimal;
        DurVal: Duration;
        GuidVal: Guid;
        IntVal: Integer;
        TimeVal: Time;
    begin
        case FldRef.Type of
            FldRef.Type::Boolean:
                begin
                    Evaluate(BoolVal, FieldValue);
                    FldRef.Validate(BoolVal);
                end;
            FldRef.Type::Integer:
                begin
                    Evaluate(IntVal, FieldValue);
                    FldRef.Validate(IntVal);
                end;
            FldRef.Type::BigInteger:
                begin
                    Evaluate(BigIntVal, FieldValue);
                    FldRef.Validate(BigIntVal);
                end;
            FldRef.Type::Decimal:
                begin
                    Evaluate(DecVal, FieldValue);
                    FldRef.Validate(DecVal);
                end;
            FldRef.Type::Date:
                begin
                    Evaluate(DateVal, FieldValue);
                    FldRef.Validate(DateVal);
                end;
            FldRef.Type::DateTime:
                begin
                    Evaluate(DateTimeVal, FieldValue);
                    FldRef.Validate(DateTimeVal);
                end;
            FldRef.Type::Time:
                begin
                    Evaluate(TimeVal, FieldValue);
                    FldRef.Validate(TimeVal);
                end;
            FldRef.Type::Duration:
                begin
                    Evaluate(DurVal, FieldValue);
                    FldRef.Validate(DurVal);
                end;
            FldRef.Type::Guid:
                begin
                    Evaluate(GuidVal, FieldValue);
                    FldRef.Validate(GuidVal);
                end;
            FldRef.Type::DateFormula:
                begin
                    Evaluate(DateFormulaVal, FieldValue);
                    FldRef.Validate(DateFormulaVal);
                end;
            FldRef.Type::Text, FldRef.Type::Code:
                begin
                    TextVal := FieldValue;
                    FldRef.Validate(TextVal);
                end;
            else
                Error('Unsupported field type %1 in field: (%2).', Format(FldRef.Type), FldRef.Name);
        end;
    end;

    local procedure SetFieldFromText(var FldRef: FieldRef; FieldValue: Text)
    var
        DateFormulaVal: DateFormula;
        BigIntVal: BigInteger;
        BoolVal: Boolean;
        TextVal: Text;
        DateVal: Date;
        DateTimeVal: DateTime;
        DecVal: Decimal;
        DurVal: Duration;
        GuidVal: Guid;
        IntVal: Integer;
        TimeVal: Time;
    begin
        case FldRef.Type of
            FldRef.Type::Boolean:
                begin
                    Evaluate(BoolVal, FieldValue);
                    FldRef.Value := BoolVal;
                end;
            FldRef.Type::Integer:
                begin
                    Evaluate(IntVal, FieldValue);
                    FldRef.Value := IntVal;
                end;
            FldRef.Type::BigInteger:
                begin
                    Evaluate(BigIntVal, FieldValue);
                    FldRef.Value := BigIntVal;
                end;
            FldRef.Type::Decimal:
                begin
                    Evaluate(DecVal, FieldValue);
                    FldRef.Value := DecVal;
                end;
            FldRef.Type::Date:
                begin
                    Evaluate(DateVal, FieldValue);
                    FldRef.Value := DateVal;
                end;
            FldRef.Type::DateTime:
                begin
                    Evaluate(DateTimeVal, FieldValue);
                    FldRef.Value := DateTimeVal;
                end;
            FldRef.Type::Time:
                begin
                    Evaluate(TimeVal, FieldValue);
                    FldRef.Value := TimeVal;
                end;
            FldRef.Type::Duration:
                begin
                    Evaluate(DurVal, FieldValue);
                    FldRef.Value := DurVal;
                end;
            FldRef.Type::Guid:
                begin
                    Evaluate(GuidVal, FieldValue);
                    FldRef.Value := GuidVal;
                end;
            FldRef.Type::DateFormula:
                begin
                    Evaluate(DateFormulaVal, FieldValue);
                    FldRef.Value := DateFormulaVal;
                end;
            FldRef.Type::Text, FldRef.Type::Code:
                begin
                    TextVal := FieldValue;
                    FldRef.Value := TextVal;
                end;
            else
                Error('Unsupported field type %1 in field: (%2).', Format(FldRef.Type), FldRef.Name);
        end;
    end;


}
