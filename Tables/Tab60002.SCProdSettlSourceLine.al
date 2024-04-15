table 60002 "SC Prod. Settl. Source Line"
{

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Nr dokumentu';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Nr wiersza';
        }
        field(4; "OBIEKT Dim Value"; Code[10])
        {
            Caption = 'Obiekt koszt';
        }
        field(5; "Fixed/Variable Costs"; Enum "SC Fixed/Variable Costs")
        {
            Caption = 'Koszt stały/zmienny';
        }
        field(6; "Dimension Set ID"; Integer)
        {
            Caption = 'Identyfikator zestawu wymiarów';
        }
        field(7; "Settlement Type"; enum "SC Settlement Type")
        {
            Caption = 'Typ rozliczenia';

        }
        field(100; "G/L Entry No."; Integer)
        {
            Caption = 'Nr zapisu K/G';
        }
        field(101; "G/L Account No."; Code[20])
        {
            Caption = 'Nr konta K/G';
            TableRelation = "G/L Account";
        }
        field(102; "Posting Date"; Date)
        {
            Caption = 'Data księgowania';
            ClosingDates = true;
        }
        field(103; "Document Type"; enum "Gen. Journal Document Type")
        {
            Caption = 'Typ dokumentu';
        }
        field(104; "G/L Entry Document No."; Code[20])
        {
            Caption = 'Nr dokumentu';

            trigger OnLookup()
            var
                IncomingDocument: Record "Incoming Document";
            begin
            end;
        }
        field(105; Description; Text[100])
        {
            Caption = 'Opis';
        }
        field(106; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Kwota';
        }
        field(107; Quantity; Decimal)
        {
            Caption = 'Ilość';
            DecimalPlaces = 0 : 5;
        }
        field(108; "VAT Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Kowata VAT';
        }
        field(109; "Debit Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Kwota debet';
        }
        field(110; "Credit Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Kwota kredyt';
        }
        field(111; "Document Date"; Date)
        {
            Caption = 'Data dokumentu';
            ClosingDates = true;
        }
        field(112; "External Document No."; Code[35])
        {
            Caption = 'Nr dokumentu zewnętrznego';
        }
        field(113; "Source Type"; Enum "Gen. Journal Source Type")
        {
            Caption = 'Typ źródła';

        }
        field(114; "Source No."; Code[20])
        {
            Caption = 'Nr źródła';
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Source Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Source Type" = CONST("Fixed Asset")) "Fixed Asset";
        }
        field(200; "Fixed Costs Amount"; Decimal)
        {
            Caption = 'Koszty stałe - suma';
        }
        field(201; "Variable Costs Amount"; Decimal)
        {
            Caption = 'Koszty zmienne - suma';
        }
        field(202; Capacity; Decimal)
        {
            Caption = 'Moc nominalna';
        }
        field(203; "Real Hours"; Decimal)
        {
            Caption = 'Godziny rzeczywiste';
        }
        field(204; "Percentage Of Use"; Decimal)
        {
            Caption = 'Procent wykorzystania';
        }
        field(205; "Amount to set"; Decimal)
        {
            Caption = 'Kwota do przypisania';
        }
        field(206; "NMP Amount"; Decimal)
        {
            Caption = 'Kwota do przypisania';
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    procedure GetNextLineNo() LineNo: Integer
    var
        ProdSettlSourceLines: Record "SC Prod. Settl. Source Line";
    begin
        ProdSettlSourceLines.RESET;
        ProdSettlSourceLines.SETRANGE("Document No.", "Document No.");
        IF ProdSettlSourceLines.FINDLAST THEN
            LineNo := ProdSettlSourceLines."Line No.";

        LineNo += 10000;
        EXIT(LineNo);
    end;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", STRSUBSTNO('%1 %2', TABLECAPTION, "G/L Entry No."));
    end;
}

