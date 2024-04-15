report 60007 "SC Process Job Settlement"
{

    ProcessingOnly = true;
    Caption = 'Rozliczenie zleceń';

    dataset
    {
        dataitem("Production Settlement Header"; "SC Prod.Settlement Header")
        {
            DataItemTableView = SORTING("No.")
                                ORDER(Ascending);
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemTableView = SORTING("Entry No.")
                                    ORDER(Ascending);

                trigger OnAfterGetRecord()
                begin
                    Window.UPDATE(1, "G/L Entry"."Entry No.");

                    CheckMandatoryDimensions;
                    CheckGLLineExist;

                    i += 1;
                    Window.UPDATE(2, i);

                    ProdSettlSourceLines.INIT;
                    ProdSettlSourceLines."Document No." := "Production Settlement Header"."No.";
                    ProdSettlSourceLines."Line No." := ProdSettlSourceLines.GetNextLineNo;
                    GetOBIEKTKosztValue(ProdSettlSourceLines);
                    GetFixedVariableCostsValue(ProdSettlSourceLines);

                    ProdSettlSourceLines."Settlement Type" := "Production Settlement Header"."Settlement Type";

                    ProdSettlSourceLines."G/L Entry No." := "G/L Entry"."Entry No.";
                    ProdSettlSourceLines."G/L Account No." := "G/L Entry"."G/L Account No.";
                    ProdSettlSourceLines."Posting Date" := "G/L Entry"."Posting Date";
                    ProdSettlSourceLines."Document Type" := "G/L Entry"."Document Type";
                    ProdSettlSourceLines."G/L Entry Document No." := "G/L Entry"."Document No.";
                    ProdSettlSourceLines.Description := "G/L Entry".Description;
                    ProdSettlSourceLines.Amount := "G/L Entry".Amount;
                    ProdSettlSourceLines.Quantity := "G/L Entry".Quantity;
                    ProdSettlSourceLines."VAT Amount" := "G/L Entry"."VAT Amount";
                    ProdSettlSourceLines."Debit Amount" := "G/L Entry"."Debit Amount";
                    ProdSettlSourceLines."Credit Amount" := "G/L Entry"."Credit Amount";
                    ProdSettlSourceLines."Document Date" := "G/L Entry"."Document Date";
                    ProdSettlSourceLines."External Document No." := "G/L Entry"."External Document No.";
                    ProdSettlSourceLines."Source Type" := "G/L Entry"."Source Type";
                    ProdSettlSourceLines."Source No." := "G/L Entry"."Source No.";
                    ProdSettlSourceLines."Dimension Set ID" := "G/L Entry"."Dimension Set ID";
                    ProdSettlSourceLines.INSERT;
                end;

                trigger OnPostDataItem()
                begin
                    "Production Settlement Header".Status := "Production Settlement Header".Status::"Lines Generated";
                    Window.CLOSE;

                    _PrepareData;
                    _GenerateSumsForSourceRows;
                end;

                trigger OnPreDataItem()
                begin
                    Window.OPEN('Trwa pobieranie zapisów K/G...\Nr zapisu: #1\Zebranych zapisów: #2');
                end;
            }

            trigger OnAfterGetRecord()
            begin
                IF StartAgain THEN BEGIN
                    ProdSettlSourceLines.RESET;
                    ProdSettlSourceLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
                    ProdSettlSourceLines.DELETEALL;
                END;
            end;

            trigger OnPostDataItem()
            begin
                "Production Settlement Header".MODIFY;
            end;

            trigger OnPreDataItem()
            begin
                IF "Production Settlement Header".GETFILTER("No.") = '' THEN
                    ERROR('Tego raportu nie można wywoływać ręcznie');
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Opcje';
                    field(StartAgain; StartAgain)
                    {
                        Caption = 'Przelicz wszystko na nowo';
                        ApplicationArea = all;
                    }
                }
            }
        }
    }



    var
        ProdSettlSourceLines: Record "SC Prod. Settl. Source Line";
        Window: Dialog;
        i: Integer;
        j: Integer;
        sumscnt: Integer;
        StartAgain: Boolean;
        CapacityFromCalendar: Boolean;

    local procedure CheckGLLineExist()
    var
        locProdSettlSourceLines: Record "SC Prod. Settl. Source Line";
    begin
        locProdSettlSourceLines.RESET;
        locProdSettlSourceLines.SETRANGE("G/L Entry No.", "G/L Entry"."Entry No.");
        locProdSettlSourceLines.SETRANGE("Settlement Type", "Production Settlement Header"."Settlement Type");
        IF locProdSettlSourceLines.FINDFIRST THEN
            CurrReport.SKIP;
    end;

    local procedure CheckMandatoryDimensions(): Boolean
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        subs: Label '''''';
        pos: Integer;
        empty: Boolean;
        notexist: Boolean;
    begin
        TempDimensionSetEntry.DELETEALL;

        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, "G/L Entry"."Dimension Set ID");
        // check PROJEKT Dimension
        IF "Production Settlement Header"."PROJEKT Dim Filter" <> '' THEN BEGIN
            TempDimensionSetEntry.RESET;
            TempDimensionSetEntry.SETRANGE("Dimension Code", 'PROJEKT');
            TempDimensionSetEntry.SETFILTER("Dimension Value Code", "Production Settlement Header"."PROJEKT Dim Filter");
            // <-- 003.287 LKA 20201022
            //IF NOT TempDimensionSetEntry.FINDFIRST THEN
            IF NOT TempDimensionSetEntry.FINDFIRST THEN BEGIN
                pos := STRPOS("Production Settlement Header"."PROJEKT Dim Filter", subs);

                TempDimensionSetEntry.RESET;
                TempDimensionSetEntry.SETRANGE("Dimension Code", 'PROJEKT');
                TempDimensionSetEntry.SETRANGE("Dimension Value Code", '');
                IF TempDimensionSetEntry.FINDFIRST AND (pos > 0) THEN
                    empty := TRUE
                ELSE
                    empty := FALSE;

                TempDimensionSetEntry.RESET;
                TempDimensionSetEntry.SETRANGE("Dimension Code", 'PROJEKT');
                IF NOT TempDimensionSetEntry.FINDFIRST AND (pos > 0) THEN
                    notexist := TRUE
                ELSE
                    notexist := FALSE;

                //IF NOT empty AND NOT notexist THEN
                IF NOT (empty XOR notexist) THEN
                    // --> 003.287
                    CurrReport.SKIP;
            END;
        END;


        // check KALKULACJA Dimension
        IF "Production Settlement Header"."KALKULACJA Dim Filter" <> '' THEN BEGIN
            TempDimensionSetEntry.RESET;
            TempDimensionSetEntry.SETRANGE("Dimension Code", 'KALKULACJA');
            TempDimensionSetEntry.SETFILTER("Dimension Value Code", "Production Settlement Header"."KALKULACJA Dim Filter");
            // <-- 003.287 LKA 20201022
            //IF NOT TempDimensionSetEntry.FINDFIRST THEN
            IF NOT TempDimensionSetEntry.FINDFIRST THEN BEGIN
                pos := STRPOS("Production Settlement Header"."KALKULACJA Dim Filter", subs);

                TempDimensionSetEntry.RESET;
                TempDimensionSetEntry.SETRANGE("Dimension Code", 'KALKULACJA');
                TempDimensionSetEntry.SETRANGE("Dimension Value Code", '');
                IF TempDimensionSetEntry.FINDFIRST AND (pos = 0) THEN
                    empty := TRUE
                ELSE
                    empty := FALSE;

                TempDimensionSetEntry.RESET;
                TempDimensionSetEntry.SETRANGE("Dimension Code", 'KALKULACJA');
                IF NOT TempDimensionSetEntry.FINDFIRST AND (pos > 0) THEN
                    notexist := TRUE
                ELSE
                    notexist := FALSE;

                IF NOT (empty XOR notexist) THEN
                    // --> 003.287
                    CurrReport.SKIP;
            END;
        END;

        // check MPK Dimension
        IF "Production Settlement Header"."MKP Dim Filter" <> '' THEN BEGIN
            TempDimensionSetEntry.RESET;
            TempDimensionSetEntry.SETRANGE("Dimension Code", 'MPK');
            TempDimensionSetEntry.SETFILTER("Dimension Value Code", "Production Settlement Header"."MKP Dim Filter");
            // <-- 003.287 LKA 20201022
            //IF NOT TempDimensionSetEntry.FINDFIRST THEN
            IF NOT TempDimensionSetEntry.FINDFIRST THEN BEGIN
                pos := STRPOS("Production Settlement Header"."MKP Dim Filter", subs);

                TempDimensionSetEntry.RESET;
                TempDimensionSetEntry.SETRANGE("Dimension Code", 'MPK');
                TempDimensionSetEntry.SETRANGE("Dimension Value Code", '');
                IF TempDimensionSetEntry.FINDFIRST AND (pos > 0) THEN
                    empty := TRUE
                ELSE
                    empty := FALSE;

                TempDimensionSetEntry.RESET;
                TempDimensionSetEntry.SETRANGE("Dimension Code", 'MPK');
                IF NOT TempDimensionSetEntry.FINDFIRST AND (pos > 0) THEN
                    notexist := TRUE
                ELSE
                    notexist := FALSE;

                IF NOT (empty XOR notexist) THEN
                    // --> 003.287
                    CurrReport.SKIP;
            END;
        END;
    end;

    local procedure GetFixedVariableCostsValue(var ProdSettlSourceLines: Record "SC Prod. Settl. Source Line")
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        ProdSettlSourceLines."Fixed/Variable Costs" := ProdSettlSourceLines."Fixed/Variable Costs"::" ";

        TempDimensionSetEntry.DELETEALL;

        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, "G/L Entry"."Dimension Set ID");

        TempDimensionSetEntry.RESET;
        TempDimensionSetEntry.SETRANGE("Dimension Code", 'Z/S');
        IF TempDimensionSetEntry.FINDFIRST THEN BEGIN

            IF TempDimensionSetEntry."Dimension Value Code" = "Production Settlement Header"."Fixed Costs Dim Value" THEN
                ProdSettlSourceLines."Fixed/Variable Costs" := ProdSettlSourceLines."Fixed/Variable Costs"::Fixed;

            IF TempDimensionSetEntry."Dimension Value Code" = "Production Settlement Header"."Variable Costs Dim Value" THEN
                ProdSettlSourceLines."Fixed/Variable Costs" := ProdSettlSourceLines."Fixed/Variable Costs"::Variable;

        END;
    end;

    local procedure GetOBIEKTKosztValue(var ProdSettlSourceLines: Record "SC Prod. Settl. Source Line")
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        MachineCenter: Record "Machine Center";
        Resource: Record "Resource";
    begin
        ProdSettlSourceLines."OBIEKT Dim Value" := '';

        TempDimensionSetEntry.DELETEALL;

        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, "G/L Entry"."Dimension Set ID");

        TempDimensionSetEntry.RESET;

        CASE "Production Settlement Header"."Settlement Type" OF

            "Production Settlement Header"."Settlement Type"::Production:
                BEGIN
                    TempDimensionSetEntry.SETRANGE("Dimension Code", 'OBIEKT KOSZT');
                    IF TempDimensionSetEntry.FINDFIRST THEN
                        IF MachineCenter.GET(TempDimensionSetEntry."Dimension Value Code") THEN
                            IF MachineCenter."Direct Unit Cost" > 0 THEN
                                ProdSettlSourceLines."OBIEKT Dim Value" := TempDimensionSetEntry."Dimension Value Code";

                END;

            "Production Settlement Header"."Settlement Type"::Assembly:
                BEGIN
                    TempDimensionSetEntry.SETRANGE("Dimension Code", 'OBIEKT KOSZT');
                    IF TempDimensionSetEntry.FINDFIRST THEN
                        IF Resource.GET(TempDimensionSetEntry."Dimension Value Code") THEN
                            ProdSettlSourceLines."OBIEKT Dim Value" := TempDimensionSetEntry."Dimension Value Code";
                END;

            "Production Settlement Header"."Settlement Type"::Job:
                BEGIN
                    TempDimensionSetEntry.SETRANGE("Dimension Code", 'MPK');
                    IF TempDimensionSetEntry.FINDFIRST THEN
                        ProdSettlSourceLines."OBIEKT Dim Value" := TempDimensionSetEntry."Dimension Value Code";
                END;

        END;
    end;

    local procedure GenerateSumRows()
    begin
        Window.OPEN('Generowanie wierszy sumarycznych @1@@@@@@@@@@');

        _PrepareData;
        _GenerateSumsForSourceRows;

        Window.CLOSE;
    end;

    local procedure _PrepareData()
    var
        DetProdSettlSourceLines: Record "SC Prod. Settl. Source Line";
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
    begin
        CLEAR(j);
        CLEAR(sumscnt);

        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
        ProdSettlSummaryLines.DELETEALL;

        DetProdSettlSourceLines.RESET;
        DetProdSettlSourceLines.SETRANGE("Document No.", "Production Settlement Header"."No.");

        sumscnt := DetProdSettlSourceLines.COUNT;
    end;

    local procedure _GenerateSumsForSourceRows()
    var
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        DetProdSettlSourceLines: Record "SC Prod. Settl. Source Line";
        DetProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
    begin
        Window.OPEN('Generowanie wierszy sumarycznych @1@@@@@@@@@@');

        // obliczanie sum szczegółowych dla pobranych zapisów księgi głównej
        DetProdSettlSourceLines.RESET;
        DetProdSettlSourceLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
        IF DetProdSettlSourceLines.FINDSET THEN
            REPEAT
                j += 1;
                Window.UPDATE(1, ROUND(j / sumscnt * 10000, 1, '='));
                ProdSettlSummaryLines.RESET;
                ProdSettlSummaryLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
                ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"Detailed Source Sum");
                ProdSettlSummaryLines.SETRANGE("OBIEKT Dim Value", DetProdSettlSourceLines."OBIEKT Dim Value");
                ProdSettlSummaryLines.SETRANGE("G/L Account No.", DetProdSettlSourceLines."G/L Account No.");
                IF ProdSettlSummaryLines.FINDFIRST THEN BEGIN

                    CASE DetProdSettlSourceLines."Fixed/Variable Costs" OF
                        DetProdSettlSourceLines."Fixed/Variable Costs"::Fixed:
                            ProdSettlSummaryLines."Fixed Costs Amount" += DetProdSettlSourceLines.Amount;
                        DetProdSettlSourceLines."Fixed/Variable Costs"::Variable:
                            ProdSettlSummaryLines."Variable Costs Amount" += DetProdSettlSourceLines.Amount;
                    END;

                    ProdSettlSummaryLines."General Cost - Sum" += DetProdSettlSourceLines.Amount;

                    ProdSettlSummaryLines.MODIFY;
                END ELSE BEGIN
                    ProdSettlSummaryLines.INIT;
                    ProdSettlSummaryLines."Document No." := "Production Settlement Header"."No.";
                    ProdSettlSummaryLines."Line Type" := ProdSettlSummaryLines."Line Type"::"Detailed Source Sum";
                    ProdSettlSummaryLines."Line No." := ProdSettlSummaryLines.GetNextLineNo;
                    ProdSettlSummaryLines."OBIEKT Dim Value" := DetProdSettlSourceLines."OBIEKT Dim Value";
                    ProdSettlSummaryLines."G/L Account No." := DetProdSettlSourceLines."G/L Account No.";

                    CASE DetProdSettlSourceLines."Fixed/Variable Costs" OF
                        DetProdSettlSourceLines."Fixed/Variable Costs"::Fixed:
                            ProdSettlSummaryLines."Fixed Costs Amount" := DetProdSettlSourceLines.Amount;
                        DetProdSettlSourceLines."Fixed/Variable Costs"::Variable:
                            ProdSettlSummaryLines."Variable Costs Amount" := DetProdSettlSourceLines.Amount;
                    END;

                    ProdSettlSummaryLines."General Cost - Sum" := DetProdSettlSourceLines.Amount;

                    ProdSettlSummaryLines.INSERT;
                END;

            UNTIL DetProdSettlSourceLines.NEXT = 0;

        //obliczanie sum ogólnych
        DetProdSettlSummaryLines.RESET;
        DetProdSettlSummaryLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
        DetProdSettlSummaryLines.SETRANGE("Line Type", DetProdSettlSummaryLines."Line Type"::"Detailed Source Sum");
        IF DetProdSettlSummaryLines.FINDSET THEN
            REPEAT
                ProdSettlSummaryLines.RESET;
                ProdSettlSummaryLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
                ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
                ProdSettlSummaryLines.SETRANGE("OBIEKT Dim Value", DetProdSettlSummaryLines."OBIEKT Dim Value");
                IF ProdSettlSummaryLines.FINDFIRST THEN BEGIN

                    ProdSettlSummaryLines."Fixed Costs Amount" += DetProdSettlSummaryLines."Fixed Costs Amount";
                    ProdSettlSummaryLines."Variable Costs Amount" += DetProdSettlSummaryLines."Variable Costs Amount";

                    ProdSettlSummaryLines."Real Hours" += DetProdSettlSummaryLines."Real Hours";
                    ProdSettlSummaryLines."General Cost - Sum" += DetProdSettlSummaryLines."General Cost - Sum";

                    ProdSettlSummaryLines.MODIFY;
                END ELSE BEGIN
                    ProdSettlSummaryLines.INIT;
                    ProdSettlSummaryLines."Document No." := "Production Settlement Header"."No.";
                    ProdSettlSummaryLines."Line Type" := ProdSettlSummaryLines."Line Type"::"General Sum";
                    ProdSettlSummaryLines."Line No." := ProdSettlSummaryLines.GetNextLineNo;
                    ProdSettlSummaryLines."OBIEKT Dim Value" := DetProdSettlSummaryLines."OBIEKT Dim Value";

                    ProdSettlSummaryLines."Fixed Costs Amount" := DetProdSettlSummaryLines."Fixed Costs Amount";
                    ProdSettlSummaryLines."Variable Costs Amount" := DetProdSettlSummaryLines."Variable Costs Amount";

                    ProdSettlSummaryLines.Capacity := DetProdSettlSummaryLines.Capacity;
                    ProdSettlSummaryLines."Real Hours" := DetProdSettlSummaryLines."Real Hours";
                    ProdSettlSummaryLines."General Cost - Sum" := DetProdSettlSummaryLines."General Cost - Sum";

                    CheckResource(ProdSettlSummaryLines);

                    ProdSettlSummaryLines.INSERT;
                END;

            UNTIL DetProdSettlSummaryLines.NEXT = 0;
        Window.CLOSE;
    end;

    local procedure _FinalizeSums()
    var
        DetProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
        ProdSettlSummaryLinesToAlloc: Record "SC Prod. Settl. Summary Lines";
        SumAllocatedFixedCost: Decimal;
        SumAllocatedVariableCost: Decimal;
        DiffAllocatedFixedCost: Decimal;
        DiffAllocatedVariableCost: Decimal;
        Percent: Decimal;
        _month: Integer;
        month: Code[10];
        VariantSuffix: Code[10];
    begin
        //sumowanie mocy nominalnej i realnej i przypisanie do wierszy bez obiektu
        DetProdSettlSummaryLines.RESET;
        DetProdSettlSummaryLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
        DetProdSettlSummaryLines.SETRANGE("Line Type", DetProdSettlSummaryLines."Line Type"::"General Sum");
        DetProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
        DetProdSettlSummaryLines.CALCSUMS(Capacity, "Real Hours");

        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        ProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '%1', '');
        IF ProdSettlSummaryLines.FINDFIRST THEN BEGIN
            ProdSettlSummaryLines.Capacity := DetProdSettlSummaryLines.Capacity;
            ProdSettlSummaryLines."Real Hours" := DetProdSettlSummaryLines."Real Hours";
            ProdSettlSummaryLines.MODIFY;
        END;

        //obliczenie alokowanych kosztów
        ProdSettlSummaryLinesToAlloc.RESET;
        ProdSettlSummaryLinesToAlloc.SETRANGE("Document No.", "Production Settlement Header"."No.");
        ProdSettlSummaryLinesToAlloc.SETRANGE("Line Type", ProdSettlSummaryLinesToAlloc."Line Type"::"General Sum");
        ProdSettlSummaryLinesToAlloc.SETFILTER("OBIEKT Dim Value", '%1', '');
        IF ProdSettlSummaryLinesToAlloc.FINDFIRST THEN BEGIN
            ProdSettlSummaryLines.RESET;
            ProdSettlSummaryLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
            ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
            ProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
            ProdSettlSummaryLines.SETCURRENTKEY("OBIEKT Dim Value");
            IF ProdSettlSummaryLines.FINDSET THEN
                REPEAT
                    //IF ProdSettlSummaryLinesToAlloc.Capacity > 0 THEN
                    //  ProdSettlSummaryLines."Allocated Fixed Costs" := ProdSettlSummaryLinesToAlloc."Fixed Costs Amount" / ProdSettlSummaryLinesToAlloc.Capacity * ProdSettlSummaryLines.Capacity;
                    ProdSettlSummaryLines."Allocated Fixed Costs" := ROUND(ProdSettlSummaryLines."Allocated Fixed Costs", 0.01, '=');
                    SumAllocatedFixedCost += ProdSettlSummaryLines."Allocated Fixed Costs";

                    ProdSettlSummaryLines."Allocated Variable Costs" := ProdSettlSummaryLinesToAlloc."Variable Costs Amount" / ProdSettlSummaryLinesToAlloc."Real Hours" * ProdSettlSummaryLines."Real Hours";
                    ProdSettlSummaryLines."Allocated Variable Costs" := ROUND(ProdSettlSummaryLines."Allocated Variable Costs", 0.01, '=');
                    SumAllocatedVariableCost += ProdSettlSummaryLines."Allocated Variable Costs";

                    ProdSettlSummaryLines.MODIFY;
                UNTIL ProdSettlSummaryLines.NEXT = 0;

            DiffAllocatedFixedCost := ProdSettlSummaryLinesToAlloc."Fixed Costs Amount" - SumAllocatedFixedCost;
            DiffAllocatedVariableCost := ProdSettlSummaryLinesToAlloc."Variable Costs Amount" - SumAllocatedVariableCost;

            ProdSettlSummaryLines.RESET;
            ProdSettlSummaryLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
            ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
            ProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
            ProdSettlSummaryLines.SETFILTER("Allocated Fixed Costs", '>%1', 0);
            ProdSettlSummaryLines.SETFILTER("Allocated Variable Costs", '>%1', 0);
            IF ProdSettlSummaryLines.FINDLAST THEN BEGIN
                ProdSettlSummaryLines."Allocated Fixed Costs" += DiffAllocatedFixedCost;
                ProdSettlSummaryLines."Allocated Variable Costs" += DiffAllocatedVariableCost;
                ProdSettlSummaryLines.MODIFY;
            END;

            ProdSettlSummaryLinesToAlloc."Allocated Fixed Costs" := SumAllocatedFixedCost + DiffAllocatedFixedCost;
            ProdSettlSummaryLinesToAlloc."Allocated Variable Costs" := SumAllocatedVariableCost + DiffAllocatedVariableCost;
            ProdSettlSummaryLinesToAlloc.MODIFY;
        END;


        //obliczenie sum kosztów zmiennych i stałych
        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        ProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
        ProdSettlSummaryLines.SETCURRENTKEY("OBIEKT Dim Value");
        IF ProdSettlSummaryLines.FINDSET THEN
            REPEAT
                ProdSettlSummaryLines."Variable Cost - Sum" := ProdSettlSummaryLines."Variable Costs Amount" + ProdSettlSummaryLines."Allocated Variable Costs";
                ProdSettlSummaryLines."Fixed Cost - Sum" := ProdSettlSummaryLines."Fixed Costs Amount" + ProdSettlSummaryLines."Allocated Fixed Costs";

                CountItemLedgerEntryData(ProdSettlSummaryLines);

                CalculateProdData(ProdSettlSummaryLines);

                ProdSettlSummaryLines.MODIFY;
            UNTIL ProdSettlSummaryLines.NEXT = 0;

        // obliczanie pozostałych sum ogólnych (podsumoiwania w pierwszym wierszu bez obiektu)
        ProdSettlSummaryLinesToAlloc.RESET;
        ProdSettlSummaryLinesToAlloc.SETRANGE("Document No.", "Production Settlement Header"."No.");
        ProdSettlSummaryLinesToAlloc.SETRANGE("Line Type", ProdSettlSummaryLinesToAlloc."Line Type"::"General Sum");
        ProdSettlSummaryLinesToAlloc.SETFILTER("OBIEKT Dim Value", '%1', '');
        IF ProdSettlSummaryLinesToAlloc.FINDFIRST THEN BEGIN
            ProdSettlSummaryLines.RESET;
            ProdSettlSummaryLines.SETRANGE("Document No.", "Production Settlement Header"."No.");
            ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
            ProdSettlSummaryLines.SETFILTER("OBIEKT Dim Value", '<>%1', '');
            ProdSettlSummaryLines.CALCSUMS("Fixed Cost - Sum", "Variable Cost - Sum", "NMP Amount", "Direct Cost", "Fixed Amount To Post", "Fixed Time To Post", "Variable Time To Post");

            ProdSettlSummaryLinesToAlloc."Fixed Cost - Sum" := ProdSettlSummaryLines."Fixed Cost - Sum";
            ProdSettlSummaryLinesToAlloc."Variable Cost - Sum" := ProdSettlSummaryLines."Variable Cost - Sum";
            ProdSettlSummaryLinesToAlloc."NMP Amount" := ProdSettlSummaryLines."NMP Amount";
            ProdSettlSummaryLinesToAlloc."Direct Cost" := ProdSettlSummaryLines."Direct Cost";
            ProdSettlSummaryLinesToAlloc."Fixed Amount To Post" := ProdSettlSummaryLines."Fixed Amount To Post";
            ProdSettlSummaryLinesToAlloc."Fixed Time To Post" := ProdSettlSummaryLines."Fixed Time To Post";
            ProdSettlSummaryLinesToAlloc."Variable Time To Post" := ProdSettlSummaryLines."Variable Time To Post";
            ProdSettlSummaryLinesToAlloc.MODIFY;
        END;
    end;

    local procedure CountItemLedgerEntryData(var ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        IF ProdSettlSummaryLines."OBIEKT Dim Value" = '' THEN
            EXIT;

        ItemLedgerEntry.RESET;
        ItemLedgerEntry.SETRANGE("Item No.", "Production Settlement Header"."Fixed Cost Item");
        ItemLedgerEntry.SETRANGE("Variant Code", ProdSettlSummaryLines."Variant Code");
        ItemLedgerEntry.CALCSUMS(Quantity);
        ProdSettlSummaryLines."Posted Fixed Time" := ItemLedgerEntry.Quantity;

        ItemLedgerEntry.RESET;
        ItemLedgerEntry.SETRANGE("Item No.", "Production Settlement Header"."Variable Cost Item");
        ItemLedgerEntry.SETRANGE("Variant Code", ProdSettlSummaryLines."Variant Code");
        ItemLedgerEntry.CALCSUMS(Quantity);
        ProdSettlSummaryLines."Posted Variable Time" := ItemLedgerEntry.Quantity;
    end;

    local procedure CalculateProdData(var _ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines")
    var
        MachineCenter: Record "Machine Center";
    begin
        _ProdSettlSummaryLines.Capacity := _ProdSettlSummaryLines."Real Hours";

        /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
        /*
        IF "Production Settlement Header"."Settlement Type" = "Production Settlement Header"."Settlement Type"::Production THEN BEGIN
            IF (_ProdSettlSummaryLines."OBIEKT Dim Value" <> '') AND MachineCenter.GET(_ProdSettlSummaryLines."OBIEKT Dim Value") THEN
                IF MachineCenter."Default Capacity" > _ProdSettlSummaryLines."Real Hours" THEN
                    _ProdSettlSummaryLines.Capacity := MachineCenter."Default Capacity";
        END;
        */
    end;

    local procedure CheckResource(var _ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines")
    var
        Resource: Record "Resource";
        ResourceGroup: Record "Resource Group";
    begin
        IF _ProdSettlSummaryLines."OBIEKT Dim Value" = '' THEN
            EXIT;

        IF ResourceGroup.GET(_ProdSettlSummaryLines."OBIEKT Dim Value") THEN
            _ProdSettlSummaryLines."Resource Group Filter" := ResourceGroup."Default Resource Group Filter";

    end;
}

