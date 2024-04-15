table 60000 "SC Prod. Settl. Summary Lines"
{
    Caption = 'Nagłówek dokumentu rozliczenia produkcji';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Nr dokumentu';
        }
        field(2; "Line Type"; enum "SC Prod. Settl. Line Type")
        {
            Caption = 'Typ wiersza';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Nr wiersza';
        }
        field(4; "OBIEKT Dim Value"; Code[10])
        {
            Caption = 'Obiekt Koszt';
        }
        field(5; "Fixed/Variable Costs"; enum "SC Fixed/Variable Costs")
        {
            Caption = 'Koszty stałe/zmienne';

        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Kod wariantu';
        }
        field(7; "Fixed Cost Item"; Code[20])
        {
            CalcFormula = Lookup("SC Prod.Settlement Header"."Fixed Cost Item" WHERE("No." = FIELD("Document No.")));
            Caption = 'Zapas kosztów stałych';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = Item;
        }
        field(8; "Variable Cost Item"; Code[20])
        {
            CalcFormula = Lookup("SC Prod.Settlement Header"."Variable Cost Item" WHERE("No." = FIELD("Document No.")));
            Caption = 'Zapas kosztów zmiennych';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = Item;
        }
        field(101; "G/L Account No."; Code[20])
        {
            Caption = 'Nr konta K/G';
            TableRelation = "G/L Account";
        }
        field(102; "Production Order No."; Code[20])
        {
            Caption = 'Nr zlecenia produkcyjnego';
        }
        field(103; "Prod. Order Line No."; Integer)
        {
            Caption = 'Nr wiersza zlec. prod.';
        }
        field(104; "Direct Cost"; Decimal)
        {
            Caption = 'Zmienne - zaksięgowane';
        }
        field(105; "Job No."; Code[20])
        {
            Caption = 'Nr zlecenia';
        }
        field(106; "Job Task No."; Code[20])
        {
            Caption = 'Nr zadania zlecenia';
        }
        field(107; "Job Planning Line No."; Integer)
        {
            Caption = 'Nr wiersza planowania zlecenia';
        }
        field(200; "Fixed Costs Amount"; Decimal)
        {
            Caption = 'Koszty stałe';
        }
        field(201; "Variable Costs Amount"; Decimal)
        {
            Caption = 'Koszty zmienne';
        }
        field(202; Capacity; Decimal)
        {
            Caption = 'Moc nominalna';

            trigger OnValidate()
            begin
                IF "OBIEKT Dim Value" = '' THEN
                    ERROR('Nie można modyfikować sumy mocy nominalnej');

                IF Capacity < "Real Hours" THEN
                    ERROR('Moc nominalna nie może być mniejsza niż godziny rzeczywiste');

                CalculateCosts;
            end;
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
            Enabled = false;
        }
        field(206; "NMP Amount"; Decimal)
        {
            Caption = 'Kwota NMP';
        }
        field(207; "Allocated Fixed Costs"; Decimal)
        {
            Caption = 'Alokowane koszty stałe';
        }
        field(208; "Allocated Variable Costs"; Decimal)
        {
            Caption = 'Alokowane koszty zmienne';
        }
        field(209; "Fixed Cost - Sum"; Decimal)
        {
            Caption = 'Suma kosztów stałych';
        }
        field(210; "Variable Cost - Sum"; Decimal)
        {
            Caption = 'Suma kosztów zmiennych';
        }
        field(211; "Fixed Amount To Post"; Decimal)
        {
            Caption = 'Do zaksięgowania - stałe';
        }
        field(212; "Posted Fixed Time"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Fixed Cost Item"),
                                                                  "Variant Code" = FIELD("Variant Code"),
                                                                  "Entry Type" = CONST("Positive Adjmt.")));
            Caption = 'Przyjęte godziny nominalne';
            FieldClass = FlowField;
        }
        field(213; "Posted Variable Time"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Variable Cost Item"),
                                                                  "Variant Code" = FIELD("Variant Code"),
                                                                  "Entry Type" = CONST("Positive Adjmt.")));
            Caption = 'Przyjęte godziny rzeczywiste';
            FieldClass = FlowField;
        }
        field(214; "Fixed Time To Post"; Decimal)
        {
            Caption = 'Godziny nominalne do przyjęcia';
        }
        field(215; "Variable Time To Post"; Decimal)
        {
            Caption = 'Godziny rzeczywiste do przyjęcia';
        }
        field(216; "Consummated Time"; Decimal)
        {
            CalcFormula = - Sum("Item Ledger Entry".Quantity WHERE("Order Type" = CONST(Production),
                                                                   "Order No." = FIELD("Production Order No."),
                                                                   "Order Line No." = FIELD("Prod. Order Line No."),
                                                                   "Item No." = FIELD("Variable Cost Item"),
                                                                   "Variant Code" = FIELD("Variant Code")));

            Caption = 'Consummated Time';
            Editable = false;
            FieldClass = FlowField;
        }
        field(217; "Time To Consum"; Decimal)
        {
            Caption = 'Godziny do zużycia';
        }
        field(218; "Variable Amount To Post"; Decimal)
        {
            Caption = 'Do zaksięgowania - zmienne';
        }
        field(219; "General Cost - Sum"; Decimal)
        {
            Caption = 'Suma kosztów';
        }
        field(220; "Amount to Settlement"; Decimal)
        {
            Caption = 'Koszty do rozliczenia';
        }
        field(300; "Assembly Item No."; Code[20])
        {
            CalcFormula = Lookup("Posted Assembly Header"."Item No." WHERE("No." = FIELD("Production Order No.")));
            Caption = 'Zapas zlecenia kompletacji';
            Editable = false;
            FieldClass = FlowField;
        }
        field(301; "Posted Assembly Qty"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Document No." = FIELD("Production Order No."),
                                                                  "Entry Type" = CONST("Assembly Output")));
            Caption = 'Zaksięgowana ilość';
            Editable = false;
            FieldClass = FlowField;
        }
        field(302; "Posted Asb. Real Cost"; Decimal)
        {
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Item Ledger Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Zaksięgowane koszty rzeczywiste';
            Editable = false;
            FieldClass = FlowField;
        }
        field(303; "Item Ledger Entry No."; Integer)
        {
            CalcFormula = Lookup("Item Ledger Entry"."Entry No." WHERE("Document No." = FIELD("Production Order No."),
                                                                        "Entry Type" = CONST("Assembly Output")));
            Caption = 'Nr zapisu ks. zapasów';
            FieldClass = FlowField;
        }
        field(304; "Resource Group Filter"; Text[250])
        {
            Caption = 'Filtr grupy zasobów';
        }
        field(305; "Posted Costs"; Decimal)
        {
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Document No." = FIELD("Document No."),
                                                                          "Entry Type" = CONST(Revaluation),
                                                                          "Item Ledger Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Rozliczenie produkcji - podsumowanie';
            Editable = false;
            FieldClass = FlowField;
        }
        field(306; "Work Type Code"; Code[10])
        {
            Caption = 'Typ pracy';
        }
        field(307; "Prod. Order Status"; enum "Production Order Status")
        {
            CalcFormula = Lookup("Production Order".Status WHERE("No." = FIELD("Production Order No.")));
            Caption = 'Stan';
            Description = '003.312';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line Type", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Document No.", "Line Type", "OBIEKT Dim Value", "Line No.")
        {
        }
        key(Key3; "Document No.", "Production Order No.", "Prod. Order Line No.", "Line Type", "OBIEKT Dim Value")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SumProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        ProductionSettlementHeader: Record "SC Prod.Settlement Header";
        Window: Dialog;

    procedure GetNextLineNo() LineNo: Integer
    var
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
    begin
        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", "Line Type");
        IF ProdSettlSummaryLines.FINDLAST THEN
            LineNo := ProdSettlSummaryLines."Line No.";

        LineNo += 10000;
        EXIT(LineNo);
    end;

    procedure CalculateFixedTimeToPost(): Decimal
    begin
        CALCFIELDS("Posted Fixed Time");
        EXIT(Capacity - "Posted Fixed Time");
    end;

    procedure CalculateVariableTimeToPost(): Decimal
    begin
        CALCFIELDS("Posted Variable Time");
        EXIT("Real Hours" - "Posted Variable Time");
    end;

    procedure CalculateVariableAmountToPost(): Decimal
    begin
        EXIT("Variable Cost - Sum" - "Direct Cost");
    end;

    procedure CalculateUnitFixedCost(): Decimal
    begin
        GetGLSetup;
        IF Capacity > 0 THEN
            EXIT(ROUND("Fixed Cost - Sum" / Capacity, GeneralLedgerSetup."Unit-Amount Rounding Precision", '='));
    end;

    procedure CalculateUnitVariableCost() Output: Decimal
    var
        AmountToPost: Decimal;
    begin
        Output := 0;
        AmountToPost := 0;

        GetGLSetup;
        IF "Real Hours" > 0 THEN BEGIN
            ProductionSettlementHeader.GET(Rec."Document No.");
            CALCFIELDS("Posted Variable Time");
            AmountToPost := CalculateProdAmountToPost;
            if AmountToPost <> 0 then
                CASE ProductionSettlementHeader."Document Type" OF
                    ProductionSettlementHeader."Document Type"::Settlement:
                        Output := ROUND(AmountToPost / "Real Hours", GeneralLedgerSetup."Unit-Amount Rounding Precision", '=');
                    ProductionSettlementHeader."Document Type"::Correction:
                        Output := ROUND(AmountToPost / "Posted Variable Time", GeneralLedgerSetup."Unit-Amount Rounding Precision", '=');
                END
        END;

        EXIT(Output);
    end;

    procedure CalculateGeneralSumToPost(): Decimal
    begin
        EXIT("General Cost - Sum" - "Direct Cost");
    end;

    procedure CalculateTimeToConsum(): Decimal
    begin
        EXIT("Real Hours" - "Consummated Time");
    end;

    procedure CalculateProdAmountToPost() Output: Decimal
    begin
        ProductionSettlementHeader.GET(Rec."Document No.");

        CASE ProductionSettlementHeader."Document Type" OF
            ProductionSettlementHeader."Document Type"::Settlement:
                Output := "Amount to Settlement" - "Direct Cost";
            ProductionSettlementHeader."Document Type"::Correction:
                Output := "Amount to Settlement";
        END;

        EXIT(Output);
    end;

    local procedure GetGLSetup()
    begin
        GeneralLedgerSetup.GET;
    end;

    local procedure CalculateCosts()
    begin
        GetSummaryRecord;
        _UpdateRecordData;
        _UpdateGeneralSums;
    end;

    local procedure _UpdateGeneralSums()
    var
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        cap: Decimal;
    begin
        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        ProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
        ProdSettlSummaryLines.CALCSUMS(Capacity);

        IF Capacity = 0 THEN
            cap := -xRec.Capacity
        ELSE
            cap := Capacity;

        SumProdSettlSummaryLines.Capacity := ProdSettlSummaryLines.Capacity + cap;
        SumProdSettlSummaryLines.MODIFY;
    end;

    local procedure _UpdateRecordData()
    begin
    end;

    local procedure GetSummaryRecord()
    begin
        SumProdSettlSummaryLines.RESET;
        SumProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        SumProdSettlSummaryLines.SETRANGE("Line Type", SumProdSettlSummaryLines."Line Type"::"General Sum");
        SumProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '%1', '');
        SumProdSettlSummaryLines.FINDFIRST;
    end;

    procedure CalcuateCostAllocation()
    var
        SumProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        SumAllocatedFixedCost: Decimal;
        SumAllocatedVariableCost: Decimal;
        DiffAllocatedFixedCost: Decimal;
        DiffAllocatedVariableCost: Decimal;
        Percent: Decimal;
        AmountToSet: Decimal;
        GeneralSum: Decimal;
        locAmt: Decimal;
        VariableCostSum: Decimal;
        FixedCostSum: Decimal;
        AmountToSetSum: Decimal;
    begin
        SumProdSettlSummaryLines.RESET;
        SumProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        SumProdSettlSummaryLines.SETRANGE("Line Type", SumProdSettlSummaryLines."Line Type"::"General Sum");
        SumProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '%1', '');
        SumProdSettlSummaryLines.FINDFIRST;

        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        ProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
        IF ProdSettlSummaryLines.FINDSET THEN
            REPEAT

                IF SumProdSettlSummaryLines.Capacity > 0 THEN
                    ProdSettlSummaryLines."Allocated Fixed Costs" := SumProdSettlSummaryLines."Fixed Costs Amount" / SumProdSettlSummaryLines.Capacity * ProdSettlSummaryLines.Capacity;
                ProdSettlSummaryLines."Allocated Fixed Costs" := ROUND(ProdSettlSummaryLines."Allocated Fixed Costs", 0.01, '=');
                SumAllocatedFixedCost += ProdSettlSummaryLines."Allocated Fixed Costs";

                ProdSettlSummaryLines."Allocated Variable Costs" := SumProdSettlSummaryLines."Variable Costs Amount" / SumProdSettlSummaryLines."Real Hours" * ProdSettlSummaryLines."Real Hours";
                ProdSettlSummaryLines."Allocated Variable Costs" := ROUND(ProdSettlSummaryLines."Allocated Variable Costs", 0.01, '=');
                SumAllocatedVariableCost += ProdSettlSummaryLines."Allocated Variable Costs";

                ProdSettlSummaryLines.MODIFY;


            UNTIL ProdSettlSummaryLines.NEXT = 0;

        DiffAllocatedFixedCost := SumProdSettlSummaryLines."Fixed Costs Amount" - SumAllocatedFixedCost;
        DiffAllocatedVariableCost := SumProdSettlSummaryLines."Variable Costs Amount" - SumAllocatedVariableCost;

        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        ProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
        ProdSettlSummaryLines.SETFILTER("Allocated Fixed Costs", '>%1', 0);
        ProdSettlSummaryLines.SETFILTER("Allocated Variable Costs", '>%1', 0);
        IF ProdSettlSummaryLines.FINDLAST THEN BEGIN
            ProdSettlSummaryLines."Allocated Fixed Costs" += DiffAllocatedFixedCost;
            ProdSettlSummaryLines."Allocated Variable Costs" += DiffAllocatedVariableCost;
            ProdSettlSummaryLines.MODIFY;
        END;

        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        ProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
        ProdSettlSummaryLines.CALCSUMS(Capacity, "Real Hours");


        SumProdSettlSummaryLines."Allocated Fixed Costs" := SumAllocatedFixedCost + DiffAllocatedFixedCost;
        SumProdSettlSummaryLines."Allocated Variable Costs" := SumAllocatedVariableCost + DiffAllocatedVariableCost;
        SumProdSettlSummaryLines.Capacity := ProdSettlSummaryLines.Capacity;
        SumProdSettlSummaryLines."Real Hours" := ProdSettlSummaryLines."Real Hours";
        SumProdSettlSummaryLines.MODIFY;


        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        ProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
        IF ProdSettlSummaryLines.FINDSET THEN
            REPEAT

                ProdSettlSummaryLines."Variable Cost - Sum" := ProdSettlSummaryLines."Variable Costs Amount" + ProdSettlSummaryLines."Allocated Variable Costs";
                ProdSettlSummaryLines."Fixed Cost - Sum" := ProdSettlSummaryLines."Fixed Costs Amount" + ProdSettlSummaryLines."Allocated Fixed Costs";

                VariableCostSum += ProdSettlSummaryLines."Variable Cost - Sum";
                FixedCostSum += ProdSettlSummaryLines."Fixed Cost - Sum";

                ProdSettlSummaryLines."General Cost - Sum" := ProdSettlSummaryLines."Variable Cost - Sum" + ProdSettlSummaryLines."Fixed Cost - Sum";
                GeneralSum += ProdSettlSummaryLines."General Cost - Sum";

                ProdSettlSummaryLines.MODIFY;

            UNTIL ProdSettlSummaryLines.NEXT = 0;

        SumProdSettlSummaryLines."General Cost - Sum" := GeneralSum;
        SumProdSettlSummaryLines."Variable Cost - Sum" := VariableCostSum;
        SumProdSettlSummaryLines."Fixed Cost - Sum" := FixedCostSum;
        SumProdSettlSummaryLines.MODIFY;

        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        ProdSettlSummaryLines.SETCURRENTKEY("OBIEKT Dim Value");
        IF ProdSettlSummaryLines.FINDSET THEN
            REPEAT
                IF ProdSettlSummaryLines.Capacity > 0 THEN BEGIN
                    ProdSettlSummaryLines."Percentage Of Use" := ROUND(ProdSettlSummaryLines."Real Hours" / ProdSettlSummaryLines.Capacity * 100, 0.01, '=');

                    Percent := ProdSettlSummaryLines."Real Hours" / ProdSettlSummaryLines.Capacity * 100;
                    IF Percent > 100 THEN
                        Percent := 100;

                    AmountToSet := ROUND(ProdSettlSummaryLines."Variable Cost - Sum" + (ProdSettlSummaryLines."Fixed Cost - Sum" * (Percent / 100)));

                    ProdSettlSummaryLines."NMP Amount" := (ProdSettlSummaryLines."Variable Cost - Sum" + ProdSettlSummaryLines."Fixed Cost - Sum") - AmountToSet;

                    //<-- 001.348 MKI 20201218
                    IF ProdSettlSummaryLines."Real Hours" = 0 THEN
                        ProdSettlSummaryLines."NMP Amount" += ProdSettlSummaryLines.CalculateProdAmountToPost;
                    //--> 001.348

                    ProdSettlSummaryLines."Fixed Amount To Post" := ProdSettlSummaryLines."Amount to set" - ProdSettlSummaryLines."Direct Cost";

                    ProdSettlSummaryLines."Amount to Settlement" := AmountToSet;
                    IF ProdSettlSummaryLines."OBIEKT Dim Value" <> '' THEN
                        AmountToSetSum += AmountToSet;

                    ProdSettlSummaryLines.MODIFY;
                END;

            UNTIL ProdSettlSummaryLines.NEXT = 0;

        SumProdSettlSummaryLines."Amount to Settlement" := AmountToSetSum;
        SumProdSettlSummaryLines."NMP Amount" := SumProdSettlSummaryLines."General Cost - Sum" - AmountToSetSum;
        SumProdSettlSummaryLines.MODIFY;

        ProductionSettlementHeader.GET("Document No.");

        IF ProductionSettlementHeader."Settlement Type" = ProductionSettlementHeader."Settlement Type"::Assembly THEN BEGIN
            SumProdSettlSummaryLines.RESET;
            SumProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
            SumProdSettlSummaryLines.SETRANGE("Line Type", SumProdSettlSummaryLines."Line Type"::"General Sum");
            SumProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
            IF SumProdSettlSummaryLines.FINDSET THEN
                REPEAT
                    CLEAR(locAmt);
                    ProdSettlSummaryLines.RESET;
                    ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
                    ProdSettlSummaryLines.SETRANGE("OBIEKT Dim Value", SumProdSettlSummaryLines."OBIEKT Dim Value");
                    ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"Detailed Dest Sum");
                    IF ProdSettlSummaryLines.FINDSET THEN
                        REPEAT
                            ProdSettlSummaryLines."Fixed Amount To Post" := ROUND(ProdSettlSummaryLines."Real Hours" / SumProdSettlSummaryLines.Capacity * SumProdSettlSummaryLines.CalculateGeneralSumToPost);
                            ProdSettlSummaryLines.MODIFY;
                            locAmt += ProdSettlSummaryLines."Fixed Amount To Post";
                        UNTIL ProdSettlSummaryLines.NEXT = 0;

                    IF locAmt <> SumProdSettlSummaryLines.CalculateGeneralSumToPost THEN BEGIN
                        ProdSettlSummaryLines."Fixed Amount To Post" += (SumProdSettlSummaryLines.CalculateGeneralSumToPost - locAmt);
                        ProdSettlSummaryLines.MODIFY;
                    END;
                    // <-- 003.168 MKI 20200804
                    IF SumProdSettlSummaryLines."Percentage Of Use" = 0 THEN BEGIN
                        SumProdSettlSummaryLines."NMP Amount" := SumProdSettlSummaryLines.CalculateGeneralSumToPost;
                        SumProdSettlSummaryLines.MODIFY;
                    END;
                // --> 003.168
                UNTIL SumProdSettlSummaryLines.NEXT = 0;

        END;
    end;

    procedure CalculateJobTime()
    var
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        ProductionSettlementHeader: Record "SC Prod.Settlement Header";
        DetProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        GenSum: Decimal;
        JobTask: Record "Job task";
        TempTimeSheetLine: Record "Time Sheet Line" temporary;
    begin
        ProductionSettlementHeader.GET("Document No.");
        CLEAR(GenSum);

        DetProdSettlSummaryLines.RESET;
        DetProdSettlSummaryLines.SETRANGE("Document No.", ProductionSettlementHeader."No.");
        DetProdSettlSummaryLines.SETRANGE("Line Type", DetProdSettlSummaryLines."Line Type"::"Detailed Dest Sum");
        DetProdSettlSummaryLines.DELETEALL;

        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        ProdSettlSummaryLines.MODIFYALL("Real Hours", 0);
        ProdSettlSummaryLines.MODIFYALL("Variable Amount To Post", 0);

        COMMIT;

        Window.OPEN('Pobieranie kart pracy...\Nr karty pracy: #1');

        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        IF ProdSettlSummaryLines.FINDSET THEN
            REPEAT
                IF ProdSettlSummaryLines."Resource Group Filter" = '' THEN
                    ERROR('Należy uzupepłnić wartość filtra grupy zasobów przy zapisie z obiektem nr %1', ProdSettlSummaryLines."OBIEKT Dim Value");

                TimeSheetLine.RESET;
                TimeSheetLine.SETRANGE("Time Sheet Starting Date", ProductionSettlementHeader."Date From", ProductionSettlementHeader."Date To");
                /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
                /*
                TimeSheetLine.SETAUTOCALCFIELDS("Resource No.", "Resource Group No.");
                TimeSheetLine.SETFILTER("Resource Group No.", ProdSettlSummaryLines."Resource Group Filter");
                */
                IF ProductionSettlementHeader."Work Type Code Filter" <> '' THEN
                    TimeSheetLine.SETFILTER("Work Type Code", ProductionSettlementHeader."Work Type Code Filter");
                IF TimeSheetLine.FINDSET THEN
                    REPEAT
                        Window.UPDATE(1, TimeSheetLine."Time Sheet No.");
                        //IF JobTask.GET(TimeSheetLine."Job No.", TimeSheetLine."Job Task No.") THEN BEGIN
                        // aktualizacja wiersza sumy ogólnej o godziny z kart pracy
                        TimeSheetLine.CALCFIELDS("Total Quantity");
                        ProdSettlSummaryLines."Real Hours" += TimeSheetLine."Total Quantity";
                        ProdSettlSummaryLines.MODIFY;

                        // odłożenie wiesza sumy szczegółowej
                        DetProdSettlSummaryLines.RESET;
                        DetProdSettlSummaryLines.SETRANGE("Document No.", ProdSettlSummaryLines."Document No.");
                        DetProdSettlSummaryLines.SETRANGE("OBIEKT Dim Value", ProdSettlSummaryLines."OBIEKT Dim Value");
                        DetProdSettlSummaryLines.SETRANGE("Job No.", TimeSheetLine."Job No.");
                        DetProdSettlSummaryLines.SETRANGE("Job Task No.", TimeSheetLine."Job Task No.");

                        /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
                        /*
                        DetProdSettlSummaryLines.SETRANGE("Job Planning Line No.", TimeSheetLine."Job Planinng Line");
                        */

                        DetProdSettlSummaryLines.SETRANGE("Work Type Code", TimeSheetLine."Work Type Code");
                        IF DetProdSettlSummaryLines.FINDFIRST THEN BEGIN
                            DetProdSettlSummaryLines."Real Hours" += TimeSheetLine."Total Quantity";
                            DetProdSettlSummaryLines.MODIFY;
                        END ELSE BEGIN
                            DetProdSettlSummaryLines.INIT;
                            DetProdSettlSummaryLines."Document No." := "Document No.";
                            DetProdSettlSummaryLines."Line Type" := DetProdSettlSummaryLines."Line Type"::"Detailed Dest Sum";
                            DetProdSettlSummaryLines."Line No." := DetProdSettlSummaryLines.GetNextLineNo;

                            DetProdSettlSummaryLines."OBIEKT Dim Value" := ProdSettlSummaryLines."OBIEKT Dim Value";
                            DetProdSettlSummaryLines."Resource Group Filter" := ProdSettlSummaryLines."Resource Group Filter";
                            DetProdSettlSummaryLines."Job No." := TimeSheetLine."Job No.";
                            DetProdSettlSummaryLines."Job Task No." := TimeSheetLine."Job Task No.";

                            /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
                            /*
                            DetProdSettlSummaryLines."Job Planning Line No." := TimeSheetLine."Job Planinng Line";
                            */

                            DetProdSettlSummaryLines."Work Type Code" := TimeSheetLine."Work Type Code";
                            DetProdSettlSummaryLines."Real Hours" := TimeSheetLine."Total Quantity";
                            DetProdSettlSummaryLines.INSERT;
                        END;
                    /*END ELSE BEGIN
                      TempTimeSheetLine.INIT;
                      TempTimeSheetLine := TimeSheetLine;
                      TempTimeSheetLine.INSERT;
                    END;*/
                    UNTIL TimeSheetLine.NEXT = 0;

            UNTIL ProdSettlSummaryLines.NEXT = 0;


        // ProdSettlSummaryLines.RESET;
        // ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        // ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        // IF ProdSettlSummaryLines.FINDSET THEN
        //  REPEAT
        //    ProdSettlSummaryLines."Percentage Of Use" := ProdSettlSummaryLines."Real Hours" / GenSum * 100;
        //    ProdSettlSummaryLines.MODIFY;
        //  UNTIL ProdSettlSummaryLines.NEXT = 0;
        Window.CLOSE;

        CalculateJobAllocation;

    end;

    procedure CalculateJobAllocation()
    var
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        DetProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        GenSum: Decimal;
    begin
        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"Detailed Dest Sum");
        ProdSettlSummaryLines.MODIFYALL("Variable Amount To Post", 0);


        Window.OPEN('Trwa obliczanie alokacji kosztów...\Nr zlecenia: #1');

        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Document No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        IF ProdSettlSummaryLines.FINDSET THEN
            REPEAT
                DetProdSettlSummaryLines.RESET;
                DetProdSettlSummaryLines.SETRANGE("Document No.", ProdSettlSummaryLines."Document No.");
                DetProdSettlSummaryLines.SETRANGE("Line Type", DetProdSettlSummaryLines."Line Type"::"Detailed Dest Sum");
                DetProdSettlSummaryLines.SETRANGE("OBIEKT Dim Value", ProdSettlSummaryLines."OBIEKT Dim Value");
                IF DetProdSettlSummaryLines.FINDSET THEN
                    REPEAT
                        Window.UPDATE(1, DetProdSettlSummaryLines."Job No.");
                        DetProdSettlSummaryLines."Percentage Of Use" := DetProdSettlSummaryLines."Real Hours" / ProdSettlSummaryLines."Real Hours" * 100;
                        DetProdSettlSummaryLines."Variable Amount To Post" := ProdSettlSummaryLines."General Cost - Sum" * DetProdSettlSummaryLines."Real Hours" / ProdSettlSummaryLines."Real Hours";
                        DetProdSettlSummaryLines.MODIFY;
                    UNTIL DetProdSettlSummaryLines.NEXT = 0;
            UNTIL ProdSettlSummaryLines.NEXT = 0;
    end;
}

