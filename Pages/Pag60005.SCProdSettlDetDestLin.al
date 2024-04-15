#pragma implicitwith disable
page 60005 "SC Prod. Settl. Det. Dest. Lin"
{
    Caption = 'Szczegółowe wiersze sumaryczne';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "SC Prod. Settl. Summary Lines";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("OBIEKT Dim Value"; Rec."OBIEKT Dim Value")
                {
                    ApplicationArea = all;
                    Caption = 'Obiekt Koszt';
                }
                field("Production Order No."; Rec."Production Order No.")
                {
                    ApplicationArea = all;
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    ApplicationArea = all;
                }
                field("Real Hours"; Rec."Real Hours")
                {
                    ApplicationArea = all;

                    trigger OnAssistEdit()
                    begin
                        LookupPage(Rec.FIELDNO("Real Hours"));
                    end;
                }
                field("Direct Cost"; Rec."Direct Cost")
                {
                    ApplicationArea = all;
                }
                field("Consummated Time"; Rec."Consummated Time")
                {
                    ApplicationArea = all;
                }
                field(TimeToConsum; TimeToConsum)
                {
                    ApplicationArea = all;
                    Caption = 'Godziny do zużycia';
                }
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CALCFIELDS("Variable Cost Item");
        CalculateData;
    end;

    trigger OnOpenPage()
    begin
        Rec.SETCURRENTKEY("OBIEKT Dim Value", "Production Order No.", "Prod. Order Line No.");
    end;

    var
        ShowGLAccount: Boolean;
        TimeToConsum: Decimal;

    local procedure LookupPage(FieldNo: Integer)
    var
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        ProductionSettlementHeader: Record "SC Prod.Settlement Header";
        MachineCenter: Record "Machine Center";
        MCFilter: Text;
    begin
        ProductionSettlementHeader.GET(Rec."Document No.");
        CapacityLedgerEntry.RESET;
        MachineCenter.RESET;
        CLEAR(MCFilter);

        /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
        /*
        MachineCenter.SETRANGE("OBIEKT Dim Value Code", "OBIEKT Dim Value");
        IF MachineCenter.FINDSET THEN
            REPEAT
                IF MachineCenter."Direct Unit Cost" > 0 THEN
                    MCFilter += MachineCenter."No." + '|';
            UNTIL MachineCenter.NEXT = 0;
        */

        IF STRLEN(MCFilter) > 0 THEN
            MCFilter := COPYSTR(MCFilter, 1, STRLEN(MCFilter) - 1);


        CASE ProductionSettlementHeader."Settlement Type" OF

            ProductionSettlementHeader."Settlement Type"::Production:
                BEGIN
                    CapacityLedgerEntry.SETRANGE("Order No.", Rec."Production Order No.");
                    CapacityLedgerEntry.SETRANGE("Order Line No.", Rec."Prod. Order Line No.");
                    CapacityLedgerEntry.SETRANGE(Type, CapacityLedgerEntry.Type::"Machine Center");
                    IF Rec."OBIEKT Dim Value" <> '' THEN
                        CapacityLedgerEntry.SETFILTER("No.", MCFilter);

                END;

            ProductionSettlementHeader."Settlement Type"::Assembly:
                BEGIN
                    CapacityLedgerEntry.SETRANGE("Document No.", Rec."Production Order No.");
                    CapacityLedgerEntry.SETRANGE(Type, CapacityLedgerEntry.Type::Resource);
                    IF Rec."OBIEKT Dim Value" <> '' THEN
                        CapacityLedgerEntry.SETRANGE("No.", Rec."OBIEKT Dim Value");
                END;
        END;

        CapacityLedgerEntry.FILTERGROUP(2);
        CapacityLedgerEntry.SETRANGE("Posting Date", ProductionSettlementHeader."Date From", ProductionSettlementHeader."Date To");

        PAGE.RUN(PAGE::"Capacity Ledger Entries", CapacityLedgerEntry);
    end;

    local procedure CalculateData()
    begin
        CLEAR(TimeToConsum);

        TimeToConsum := Rec.CalculateTimeToConsum;
    end;
}

#pragma implicitwith restore

