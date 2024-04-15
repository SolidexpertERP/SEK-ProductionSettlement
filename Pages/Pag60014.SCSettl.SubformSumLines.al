#pragma implicitwith disable
page 60014 "SC Settl. Subform Sum Lines"
{
    Caption = 'Podsumowanie';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "SC Prod. Settl. Summary Lines";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("OBIEKT Dim Value"; Rec."OBIEKT Dim Value")
                {
                    ApplicationArea = all;
                    Caption = 'Obiekt Koszt';
                    Editable = false;
                    StyleExpr = MarkLine;

                    trigger OnAssistEdit()
                    begin
                        LookupPage(Rec.FIELDNO("OBIEKT Dim Value"));
                    end;
                }
                field("Resource Group Filter"; Rec."Resource Group Filter")
                {
                    ApplicationArea = all;
                }
                field("Fixed Costs Amount"; Rec."Fixed Costs Amount")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = MarkLine;

                    trigger OnAssistEdit()
                    begin
                        LookupPage(Rec.FIELDNO("Fixed Costs Amount"));
                    end;
                }
                field("Variable Costs Amount"; Rec."Variable Costs Amount")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = MarkLine;

                    trigger OnAssistEdit()
                    begin
                        LookupPage(Rec.FIELDNO("Variable Costs Amount"));
                    end;
                }
                field("General Cost - Sum"; Rec."General Cost - Sum")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Real Hours"; Rec."Real Hours")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = MarkLine;

                    trigger OnAssistEdit()
                    begin
                        LookupPage(Rec.FIELDNO("Real Hours"));
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ProductionSettlementHeader.GET(Rec."Document No.");

        MarkRecord;
        Rec.CALCFIELDS("Fixed Cost Item", "Variable Cost Item");
        CalcData;
    end;

    trigger OnOpenPage()
    begin
        Rec.SETCURRENTKEY("OBIEKT Dim Value");
    end;

    var
        ShowGLAccount: Boolean;
        MarkLine: Text;
        FixedTimeToPost: Decimal;
        VariableTimeToPost: Decimal;
        VariableAmountToPost: Decimal;
        UnitVariableCost: Decimal;
        UnitFixedCost: Decimal;
        ProductionSettlementHeader: Record "SC Prod.Settlement Header";
        GeneralSumToPost: Decimal;

    local procedure LookupPage(_FieldNo: Integer)
    var
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        CalendarEntry: Record "Calendar Entry";
        ProductionSettlementHeader: Record "SC Prod.Settlement Header";
        ProdSettlSourceLines: Record "SC Prod. Settl. Source Line";
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        MachineCenter: Record "Machine Center";
    begin

        CASE _FieldNo OF

            Rec.FIELDNO("OBIEKT Dim Value"):
                BEGIN
                    IF Rec."OBIEKT Dim Value" = '' THEN
                        EXIT;

                    MachineCenter.GET(Rec."OBIEKT Dim Value");
                    PAGE.RUN(PAGE::"Machine Center Card", MachineCenter);
                END;

            // Pola związane kosztali zmiennymi/stałymi
            Rec.FIELDNO("Fixed Costs Amount"),
            Rec.FIELDNO("Variable Costs Amount"):
                BEGIN

                    CASE Rec."Line Type" OF

                        Rec."Line Type"::"General Sum":
                            BEGIN

                                ProdSettlSummaryLines.RESET;
                                ProdSettlSummaryLines.SETRANGE("OBIEKT Dim Value", Rec."OBIEKT Dim Value");

                                ProdSettlSummaryLines.FILTERGROUP(2);
                                ProdSettlSummaryLines.SETRANGE("Document No.", Rec."Document No.");
                                ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"Detailed Source Sum");

                                PAGE.RUN(PAGE::"SC Prod. Settl. Det. Src. Line", ProdSettlSummaryLines);
                            END;

                        Rec."Line Type"::"Detailed Source Sum":
                            BEGIN

                                ProdSettlSourceLines.RESET;
                                ProdSettlSourceLines.SETRANGE("OBIEKT Dim Value", Rec."OBIEKT Dim Value");
                                ProdSettlSourceLines.SETRANGE("G/L Account No.", Rec."G/L Account No.");

                                CASE _FieldNo OF
                                    200:
                                        ProdSettlSourceLines.SETRANGE("Fixed/Variable Costs", ProdSettlSourceLines."Fixed/Variable Costs"::Fixed);
                                    201:
                                        ProdSettlSourceLines.SETRANGE("Fixed/Variable Costs", ProdSettlSourceLines."Fixed/Variable Costs"::Variable);
                                END;

                                ProdSettlSourceLines.FILTERGROUP(2);
                                ProdSettlSourceLines.SETRANGE("Document No.", Rec."Document No.");

                                PAGE.RUN(PAGE::"SC Prod. Settl. Source Lines", ProdSettlSourceLines);
                            END;

                    END;
                END;

            // Moc nominalna
            Rec.FIELDNO(Capacity):
                BEGIN
                    IF Rec."OBIEKT Dim Value" = '' THEN
                        EXIT;

                    ProductionSettlementHeader.GET(Rec."Document No.");

                    CalendarEntry.RESET;
                    CalendarEntry.SETRANGE("Capacity Type", CalendarEntry."Capacity Type"::"Machine Center");
                    CalendarEntry.SETRANGE(Date, ProductionSettlementHeader."Date From", ProductionSettlementHeader."Date To");
                    CalendarEntry.SETRANGE("No.", Rec."OBIEKT Dim Value");
                    PAGE.RUN(PAGE::"Calendar Entries", CalendarEntry);
                END;

            // godziny rzeczywiste
            Rec.FIELDNO("Direct Cost"),
            Rec.FIELDNO("Real Hours"):
                BEGIN

                    CASE Rec."Line Type" OF

                        Rec."Line Type"::"General Sum":
                            BEGIN

                                ProdSettlSummaryLines.RESET;
                                ProdSettlSummaryLines.SETRANGE("OBIEKT Dim Value", Rec."OBIEKT Dim Value");

                                ProdSettlSummaryLines.FILTERGROUP(2);
                                ProdSettlSummaryLines.SETRANGE("Document No.", Rec."Document No.");
                                ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"Detailed Dest Sum");

                                PAGE.RUN(PAGE::"SC Job Settl. Det. Dest. Lines", ProdSettlSummaryLines);
                            END;

                        Rec."Line Type"::"Detailed Dest Sum":
                            BEGIN

                                CapacityLedgerEntry.RESET;

                                IF Rec."OBIEKT Dim Value" <> '' THEN
                                    CapacityLedgerEntry.SETRANGE("No.", Rec."OBIEKT Dim Value");
                                CapacityLedgerEntry.SETRANGE("Order No.", Rec."Production Order No.");
                                CapacityLedgerEntry.SETRANGE("Order Line No.", Rec."Prod. Order Line No.");

                                PAGE.RUN(PAGE::"Capacity Ledger Entries", CapacityLedgerEntry);
                            END;

                    END;
                END;

        END;
    end;

    local procedure MarkRecord()
    var
        Resource: Record "Resource";
        ResourceGroup: Record "Resource Group";
    begin
        CLEAR(MarkLine);

        IF ProductionSettlementHeader."Settlement Type" = ProductionSettlementHeader."Settlement Type"::Assembly THEN
            EXIT;

        IF Rec."OBIEKT Dim Value" = '' THEN
            EXIT;

        /*Resource.RESET;
        Resource.SETRANGE("Resource Group No.", "OBIEKT Dim Value");
        IF NOT Resource.FINDFIRST THEN*/
        IF NOT ResourceGroup.GET(Rec."OBIEKT Dim Value") THEN
            MarkLine := 'Attention';

    end;

    local procedure CalcData()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        CLEAR(FixedTimeToPost);
        CLEAR(VariableTimeToPost);

        CLEAR(VariableAmountToPost);

        CLEAR(UnitFixedCost);
        CLEAR(UnitVariableCost);

        GeneralSumToPost := Rec.CalculateGeneralSumToPost;

        IF Rec."OBIEKT Dim Value" = '' THEN
            EXIT;

        FixedTimeToPost := Rec.CalculateFixedTimeToPost;
        VariableTimeToPost := Rec.CalculateVariableTimeToPost;

        VariableAmountToPost := Rec.CalculateVariableAmountToPost;


        UnitFixedCost := Rec.CalculateUnitFixedCost;
        UnitVariableCost := Rec.CalculateUnitVariableCost;
    end;
}

#pragma implicitwith restore

