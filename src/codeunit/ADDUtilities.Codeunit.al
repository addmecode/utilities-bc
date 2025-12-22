codeunit 50141 "ADD_Utilities"
{
    procedure GetUpdProgrBatch(TotalRowsNumber: Integer; ProgrUpdPerc: Decimal): Integer
    begin
        exit(Round(TotalRowsNumber * ProgrUpdPerc, 1, '>'));
    end;
}
