page 60002 "SC Prod. Settl. Subform Lines"
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
                field("Allocated Fixed Costs"; Rec."Allocated Fixed Costs")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = MarkLine;
                }
                field("Allocated Variable Costs"; Rec."Allocated Variable Costs")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = MarkLine;
                }
                field("Fixed Cost - Sum"; Rec."Fixed Cost - Sum")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = MarkLine;
                }
                field(UnitFixedCost; UnitFixedCost)
                {
                    ApplicationArea = all;
                    Caption = 'Koszt jednostkowy - stałe';
                    DecimalPlaces = 2 : 7;
                    Editable = false;
                }
                field("Variable Cost - Sum"; Rec."Variable Cost - Sum")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = MarkLine;
                }
                field("General Cost - Sum"; Rec."General Cost - Sum")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Amount to Settlement"; Rec."Amount to Settlement")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Direct Cost"; Rec."Direct Cost")
                {
                    ApplicationArea = all;
                    Caption = 'Koszty zaksięgowane';
                    Editable = false;
                    StyleExpr = MarkLine;

                    trigger OnAssistEdit()
                    begin
                        LookupPage(Rec.FIELDNO("Direct Cost"));
                    end;
                }
                field(VariableAmountToPost; VariableAmountToPost)
                {
                    ApplicationArea = all;
                    Caption = 'Koszty do zaksięgowania';
                    Editable = false;
                }
                field(UnitVariableCost; UnitVariableCost)
                {
                    ApplicationArea = all;
                    Caption = 'Koszt jednostkowy';
                    DecimalPlaces = 2 : 7;
                    Editable = false;
                }
                field(Capacity; Rec.Capacity)
                {
                    ApplicationArea = all;
                    StyleExpr = MarkLine;

                    trigger OnValidate()
                    begin
                        CurrPage.SAVERECORD;
                        CalcData;
                    end;
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
                field("Posted Variable Time"; Rec."Posted Variable Time")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(VariableTimeToPost; VariableTimeToPost)
                {
                    ApplicationArea = all;
                    Caption = 'Godziny rzeczywiste do przyjęcia';
                    Editable = false;
                }
                field("Percentage Of Use"; Rec."Percentage Of Use")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = MarkLine;
                }
                field("NMP Amount"; Rec."NMP Amount")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = MarkLine;
                }
            }
        }
    }

    actions
    {
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
                                IF Rec."OBIEKT Dim Value" <> '' THEN
                                    ProdSettlSummaryLines.SETRANGE("OBIEKT Dim Value", Rec."OBIEKT Dim Value");

                                ProdSettlSummaryLines.FILTERGROUP(2);
                                ProdSettlSummaryLines.SETRANGE("Document No.", Rec."Document No.");
                                ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"Detailed Dest Sum");

                                PAGE.RUN(PAGE::"SC Prod. Settl. Det. Dest. Lin", ProdSettlSummaryLines);
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
        MachineCenter: Record "Machine Center";
    begin
        CLEAR(MarkLine);

        IF ProductionSettlementHeader."Settlement Type" = ProductionSettlementHeader."Settlement Type"::Assembly THEN
            EXIT;

        IF Rec."OBIEKT Dim Value" = '' THEN
            EXIT;

        /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
        /*
        MachineCenter.GET("OBIEKT Dim Value");
        IF MachineCenter."OBIEKT Dim Value Code" = '' THEN
            MarkLine := 'Attention';
        */
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

        IF Rec."OBIEKT Dim Value" = '' THEN
            EXIT;

        FixedTimeToPost := Rec.CalculateFixedTimeToPost;
        VariableTimeToPost := Rec.CalculateVariableTimeToPost;

        VariableAmountToPost := Rec.CalculateProdAmountToPost;

        UnitFixedCost := Rec.CalculateUnitFixedCost;
        UnitVariableCost := Rec.CalculateUnitVariableCost;
    end;
}

