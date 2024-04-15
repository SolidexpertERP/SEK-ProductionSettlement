report 60005 "SC Generate Gen. Journal"
{
    ProcessingOnly = true;
    Caption = 'Generowanie dziennika';
    dataset
    {
        dataitem("Production Settlement Header"; "SC Prod.Settlement Header")
        {
            dataitem("Prod. Settl. Summary Lines"; "SC Prod. Settl. Summary Lines")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line Type", "OBIEKT Dim Value", "Line No.")
                                    WHERE("Line Type" = CONST("General Sum"),
                                          "OBIEKT Dim Value" = FILTER(<> ''));

                trigger OnAfterGetRecord()
                var
                    GenJournalLineLast: Record "Gen. Journal Line";
                    TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
                    DimensionManagement: Codeunit DimensionManagement;
                    AccountNoMPKCode: Record "SC Account No. - MPK Code";
                begin

                    LineNo := GetLineNo;

                    Window.UPDATE(1, "Prod. Settl. Summary Lines"."Production Order No.");
                    GenJournalLine.INIT;

                    LineNo := GetLineNo;
                    LineNo += 10000;

                    GenJournalLine.INIT;
                    GenJournalLine.VALIDATE(GenJournalLine."Journal Template Name", JournalTemplateName);
                    GenJournalLine.VALIDATE(GenJournalLine."Journal Batch Name", JournalBatchName);
                    GenJournalLine."Line No." := LineNo;

                    GenJournalLine.VALIDATE(GenJournalLine."Posting Date", PostingDate);
                    GenJournalLine.VALIDATE(GenJournalLine."Document No.", "Production Settlement Header"."No.");
                    GenJournalLine.VALIDATE(GenJournalLine."Account Type", GenJournalLine."Account Type"::"G/L Account");

                    IF ("Production Settlement Header"."Settlement Type" = "Production Settlement Header"."Settlement Type"::Job)
                      AND AccountNoMPKCode.GET("Prod. Settl. Summary Lines"."OBIEKT Dim Value", '') THEN BEGIN

                        GenJournalLine.VALIDATE(GenJournalLine."Account No.", AccountNoMPKCode."Account No. 6");
                        IF "Production Settlement Header"."Account No. (4*)" <> '' THEN BEGIN
                            GenJournalLine.VALIDATE(GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                            GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.", AccountNoMPKCode."Account No. 4");
                        END;

                    END ELSE BEGIN

                        GenJournalLine.VALIDATE(GenJournalLine."Account No.", "Production Settlement Header"."Account No. (6*)");
                        IF "Production Settlement Header"."Account No. (4*)" <> '' THEN BEGIN
                            GenJournalLine.VALIDATE(GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                            GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.", "Production Settlement Header"."Account No. (4*)");
                        END

                    END;

                    IF "Production Settlement Header"."Settlement Type" = "Production Settlement Header"."Settlement Type"::Job THEN BEGIN
                        IF ("Prod. Settl. Summary Lines"."NMP Amount" = 0) AND ("Prod. Settl. Summary Lines"."Real Hours" = 0) THEN
                            GenJournalLine.VALIDATE(GenJournalLine.Amount, "Prod. Settl. Summary Lines"."General Cost - Sum");
                    END ELSE
                        GenJournalLine.VALIDATE(GenJournalLine.Amount, "Prod. Settl. Summary Lines"."NMP Amount");

                    GenJournalLine.Description := "Production Settlement Header".Description;

                    IF GenJournalLine.Amount <> 0 THEN BEGIN
                        GenJournalLine.INSERT(TRUE);
                        CreateDimension(GenJournalLine, "Prod. Settl. Summary Lines", "Production Settlement Header");

                    END;

                    GenJournalLine.INIT;
                    LineNo += 10000;

                    GenJournalLine.INIT;
                    GenJournalLine.VALIDATE(GenJournalLine."Journal Template Name", JournalTemplateName);
                    GenJournalLine.VALIDATE(GenJournalLine."Journal Batch Name", JournalBatchName);
                    GenJournalLine."Line No." := LineNo;

                    GenJournalLine.VALIDATE(GenJournalLine."Posting Date", PostingDate);
                    GenJournalLine.VALIDATE(GenJournalLine."Document No.", "Production Settlement Header"."No.");
                    GenJournalLine.VALIDATE(GenJournalLine."Account Type", GenJournalLine."Account Type"::"G/L Account");

                    IF ("Production Settlement Header"."Settlement Type" = "Production Settlement Header"."Settlement Type"::Job)
                      AND AccountNoMPKCode.GET("Prod. Settl. Summary Lines"."OBIEKT Dim Value", '') THEN BEGIN

                        GenJournalLine.VALIDATE(GenJournalLine."Account No.", AccountNoMPKCode."Account No. 7");
                        IF "Production Settlement Header"."Account No. (6*)" <> '' THEN BEGIN
                            GenJournalLine.VALIDATE(GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                            GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.", AccountNoMPKCode."Account No. 6");
                        END;

                    END ELSE BEGIN

                        GenJournalLine.VALIDATE(GenJournalLine."Account No.", "Production Settlement Header"."Account No. (7*)");
                        IF "Production Settlement Header"."Account No. (6*)" <> '' THEN BEGIN
                            GenJournalLine.VALIDATE(GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                            GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.", "Production Settlement Header"."Account No. (6*)");
                        END

                    END;

                    IF "Production Settlement Header"."Settlement Type" = "Production Settlement Header"."Settlement Type"::Job THEN BEGIN
                        IF ("Prod. Settl. Summary Lines"."NMP Amount" = 0) AND ("Prod. Settl. Summary Lines"."Real Hours" = 0) THEN
                            GenJournalLine.VALIDATE(GenJournalLine.Amount, "Prod. Settl. Summary Lines"."General Cost - Sum");
                    END ELSE
                        GenJournalLine.VALIDATE(GenJournalLine.Amount, "Prod. Settl. Summary Lines"."NMP Amount");

                    GenJournalLine.Description := "Production Settlement Header".Description;

                    IF GenJournalLine.Amount <> 0 THEN BEGIN
                        GenJournalLine.INSERT(TRUE);
                        CreateDimension(GenJournalLine, "Prod. Settl. Summary Lines", "Production Settlement Header");
                    END;

                    IF "Production Settlement Header"."Settlement Type" = "Production Settlement Header"."Settlement Type"::Job THEN
                        GetAccountFromMPK;
                end;

                trigger OnPostDataItem()
                var
                    GeneralJournal: Page "General Journal";
                begin
                    Window.CLOSE;
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", JournalTemplateName);
                    GenJournalLine.SETRANGE("Journal Batch Name", JournalBatchName);
                    PAGE.RUN(39, GenJournalLine);
                end;

                trigger OnPreDataItem()
                begin
                    Window.OPEN('Tworzenie wierszy dziennika #1');
                end;
            }

            trigger OnAfterGetRecord()
            begin
                "Production Settlement Header".TESTFIELD("Account No. (4*)");
                "Production Settlement Header".TESTFIELD("Account No. (6*)");
                "Production Settlement Header".TESTFIELD("Account No. (7*)");
            end;
        }
    }

    requestpage
    {
        Caption = 'Generate Gen. Journal';
        SaveValues = true;

        layout
        {
            area(content)
            {
                field("Journal Template Name"; JournalTemplateName)
                {
                    ApplicationArea = all;
                    Caption = 'Journal Template Name';
                    TableRelation = "Gen. Journal Template" WHERE(Type = CONST(General));
                }
                field("Batch Name"; JournalBatchName)
                {
                    ApplicationArea = all;
                    Caption = 'Batch Name';
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GenJournalBatch: Record "Gen. Journal Batch";
                    begin
                        GenJournalBatch.FILTERGROUP(2);
                        GenJournalBatch.SETRANGE("Journal Template Name", JournalTemplateName);
                        IF PAGE.RUNMODAL(0, GenJournalBatch) = ACTION::LookupOK THEN
                            JournalBatchName := GenJournalBatch.Name;
                    end;

                    trigger OnValidate()
                    var
                        GenJournalBatch: Record "Gen. Journal Batch";
                    begin
                        GenJournalBatch.RESET;
                        GenJournalBatch.SETRANGE("Journal Template Name", JournalTemplateName);
                        GenJournalBatch.SETRANGE(Name, JournalBatchName);
                        IF NOT GenJournalBatch.FINDFIRST THEN BEGIN
                            MESSAGE(STRSUBSTNO('Brak instancji dziennika w określonym filtrze Nazwa szablonu dziennika: %1, Nazwa instancji: %2', JournalTemplateName, JournalBatchName));
                            JournalBatchName := '';
                        END;
                    end;
                }
                field("Account No."; AccountNo)
                {
                    ApplicationArea = all;
                    Caption = 'Account No.';
                    TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                         Blocked = CONST(false));
                    Visible = false;
                }
                field("Bal. Account No."; BalAccountNo)
                {
                    ApplicationArea = all;
                    Caption = 'Bal. Account No.';
                    TableRelation = "G/L Account";
                    Visible = false;
                }
                field(PostingDate; PostingDate)
                {
                    ApplicationArea = all;
                    Caption = 'Posting Date';
                }
            }
        }

        actions
        {
        }

        trigger OnClosePage()
        begin
            CheckJournalLine;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
    end;

    var
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10];
        AccountNo: Code[20];
        BalAccountNo: Code[20];
        Window: Dialog;
        PostingDate: Date;
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;

    local procedure CheckJournalLine()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", JournalTemplateName);
        GenJournalLine.SETRANGE("Journal Batch Name", JournalBatchName);
        IF GenJournalLine.FINDSET THEN
            IF CONFIRM('W dzienniku %1 instancji %2 znajdują się niezaksięgowane rekordy. Czy chcesz je usunąć?', FALSE, JournalTemplateName, JournalBatchName) THEN
                GenJournalLine.DELETEALL(TRUE);
    end;

    local procedure CreateDimension(var _GenJournalLine: Record "Gen. Journal Line"; _ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines"; _ProductionSettlementHeader: Record "SC Prod.Settlement Header")
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        DimVal: Code[20];
        Create: Boolean;
        Pos: Integer;
    begin
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, _GenJournalLine."Dimension Set ID");

        DefaultDimension.RESET;
        DefaultDimension.SETRANGE("Table ID", DATABASE::"G/L Account");
        DefaultDimension.SETRANGE("No.", _GenJournalLine."Account No.");
        IF DefaultDimension.FINDSET THEN
            REPEAT
                Create := FALSE;
                IF _ProductionSettlementHeader."Settlement Type" = _ProductionSettlementHeader."Settlement Type"::Job THEN BEGIN
                    IF (DefaultDimension."Dimension Code" = 'KALKULACJA') THEN
                        IF CheckFilter("Production Settlement Header"."KALKULACJA Dim Filter") THEN BEGIN
                            Create := TRUE;
                            DimVal := _ProductionSettlementHeader."KALKULACJA Dim Filter";
                        END;

                    IF (DefaultDimension."Dimension Code" = 'MPK') THEN BEGIN
                        Create := TRUE;
                        DimVal := _ProdSettlSummaryLines."OBIEKT Dim Value";
                    END;

                END;

                IF (DefaultDimension."Dimension Code" = 'OBIEKT KOSZT') AND (_ProductionSettlementHeader."Settlement Type" IN
                  [_ProductionSettlementHeader."Settlement Type"::Assembly, _ProductionSettlementHeader."Settlement Type"::Production]) THEN BEGIN
                    DimVal := _ProdSettlSummaryLines."OBIEKT Dim Value";
                    Create := TRUE;
                END;

                IF Create THEN BEGIN
                    TempDimensionSetEntry.RESET;
                    TempDimensionSetEntry.SETRANGE("Dimension Code", DefaultDimension."Dimension Code");
                    IF TempDimensionSetEntry.FINDFIRST THEN BEGIN
                        TempDimensionSetEntry.VALIDATE("Dimension Value Code", DimVal);
                        TempDimensionSetEntry.MODIFY;
                    END ELSE BEGIN
                        TempDimensionSetEntry.INIT;
                        TempDimensionSetEntry.VALIDATE("Dimension Code", DefaultDimension."Dimension Code");
                        TempDimensionSetEntry.VALIDATE("Dimension Value Code", DimVal);
                        TempDimensionSetEntry.INSERT;
                    END;
                END;


            UNTIL DefaultDimension.NEXT = 0;


        TempDimensionSetEntry.RESET;

        _GenJournalLine.VALIDATE("Dimension Set ID", DimensionManagement.GetDimensionSetID(TempDimensionSetEntry));
        GetDimFromWorkType(_GenJournalLine, _ProdSettlSummaryLines, _ProdSettlSummaryLines."Work Type Code");
        _GenJournalLine.MODIFY;
    end;

    local procedure CheckFilter(Text: Text): Boolean
    var
        i: Integer;
        Str: Text;
    begin
        FOR i := 1 TO 10 DO BEGIN
            Str := COPYSTR(Text, i, 1);
            IF Str IN ['|', '*'] THEN
                EXIT(FALSE);
        END;
        EXIT(TRUE);
    end;

    local procedure GetAccountFromMPK(): Boolean
    var
        ProdSettlSummaryLinesDetails: Record "SC Prod. Settl. Summary Lines";
        AccountNoMPKCode: Record "SC Account No. - MPK Code";
        TempProdSettlSummaryLinesDetails: Record "SC Prod. Settl. Summary Lines" temporary;
    begin
        IF TempProdSettlSummaryLinesDetails.ISTEMPORARY THEN
            TempProdSettlSummaryLinesDetails.DELETEALL;

        ProdSettlSummaryLinesDetails.RESET;
        ProdSettlSummaryLinesDetails.SETRANGE("OBIEKT Dim Value", "Prod. Settl. Summary Lines"."OBIEKT Dim Value");
        ProdSettlSummaryLinesDetails.SETRANGE("Document No.", "Prod. Settl. Summary Lines"."Document No.");
        ProdSettlSummaryLinesDetails.SETRANGE("Line Type", ProdSettlSummaryLinesDetails."Line Type"::"Detailed Dest Sum");
        IF ProdSettlSummaryLinesDetails.FINDSET THEN
            REPEAT
                FillTempProdSetttlLineDetails(TempProdSettlSummaryLinesDetails,
                  ProdSettlSummaryLinesDetails."OBIEKT Dim Value", ProdSettlSummaryLinesDetails."Work Type Code",
                  "Prod. Settl. Summary Lines"."Document No.");
            UNTIL ProdSettlSummaryLinesDetails.NEXT = 0;

        TempProdSettlSummaryLinesDetails.RESET;
        CreateGenJrnlForProdSettlDetails(TempProdSettlSummaryLinesDetails);

        IF TempProdSettlSummaryLinesDetails.COUNT > 0 THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    local procedure FillTempProdSetttlLineDetails(var TempProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines"; MPKCode: Code[20]; WorkTypeCode: Code[10]; DocumentNo: Code[20])
    var
        AccountNoMPKCode: Record "SC Account No. - MPK Code";
        ProdSettlSummaryLinesDetails: Record "SC Prod. Settl. Summary Lines";
        LocLineNo: Integer;
    begin
        IF NOT AccountNoMPKCode.GET(MPKCode, WorkTypeCode) THEN
            EXIT;

        ProdSettlSummaryLinesDetails.RESET;
        ProdSettlSummaryLinesDetails.SETRANGE("Document No.", DocumentNo);
        ProdSettlSummaryLinesDetails.SETRANGE("Line Type", ProdSettlSummaryLinesDetails."Line Type"::"Detailed Dest Sum");
        ProdSettlSummaryLinesDetails.SETRANGE("OBIEKT Dim Value", MPKCode);
        ProdSettlSummaryLinesDetails.SETRANGE("Work Type Code", WorkTypeCode);
        IF NOT (ProdSettlSummaryLinesDetails.COUNT > 0) THEN
            EXIT;

        ProdSettlSummaryLinesDetails.CALCSUMS("Variable Amount To Post");

        TempProdSettlSummaryLines.RESET;
        TempProdSettlSummaryLines.SETRANGE("Document No.", DocumentNo);
        TempProdSettlSummaryLines.SETRANGE("OBIEKT Dim Value", MPKCode);
        TempProdSettlSummaryLines.SETRANGE("Work Type Code", WorkTypeCode);
        IF TempProdSettlSummaryLines.FINDFIRST THEN
            EXIT;

        TempProdSettlSummaryLines.RESET;
        IF TempProdSettlSummaryLines.FINDLAST THEN
            LocLineNo := TempProdSettlSummaryLines."Line No." + 10000
        ELSE
            LocLineNo := 10000;

        TempProdSettlSummaryLines.INIT;
        TempProdSettlSummaryLines."Document No." := DocumentNo;
        TempProdSettlSummaryLines."Line Type" := TempProdSettlSummaryLines."Line Type"::"Detailed Dest Sum";
        TempProdSettlSummaryLines."Line No." := LocLineNo;

        TempProdSettlSummaryLines."OBIEKT Dim Value" := MPKCode;
        TempProdSettlSummaryLines."Work Type Code" := WorkTypeCode;
        TempProdSettlSummaryLines."Variable Amount To Post" := ProdSettlSummaryLinesDetails."Variable Amount To Post";
        TempProdSettlSummaryLines.INSERT;
    end;

    local procedure CreateGenJrnlForProdSettlDetails(var ProdSettlSummaryLinesDetails: Record "SC Prod. Settl. Summary Lines")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLineLast: Record "Gen. Journal Line";
        AccountNoMPKCode: Record "SC Account No. - MPK Code";
    begin
        ProdSettlSummaryLinesDetails.RESET;
        IF ProdSettlSummaryLinesDetails.FINDSET THEN
            REPEAT
                AccountNoMPKCode.GET("Prod. Settl. Summary Lines"."OBIEKT Dim Value", ProdSettlSummaryLinesDetails."Work Type Code");

                GenJournalLine.INIT;
                LineNo += 10000;

                GenJournalLine.INIT;
                GenJournalLine.VALIDATE(GenJournalLine."Journal Template Name", JournalTemplateName);
                GenJournalLine.VALIDATE(GenJournalLine."Journal Batch Name", JournalBatchName);
                GenJournalLine."Line No." := LineNo;

                GenJournalLine.VALIDATE(GenJournalLine."Posting Date", PostingDate);
                GenJournalLine.VALIDATE(GenJournalLine."Document No.", ProdSettlSummaryLinesDetails."Document No.");
                GenJournalLine.VALIDATE(GenJournalLine."Account Type", GenJournalLine."Account Type"::"G/L Account");
                GenJournalLine.VALIDATE(GenJournalLine."Account No.", AccountNoMPKCode."Account No. 6");
                GenJournalLine.VALIDATE(GenJournalLine.Amount, ProdSettlSummaryLinesDetails."Variable Amount To Post");

                IF AccountNoMPKCode."Account No. 4" <> '' THEN BEGIN
                    GenJournalLine.VALIDATE(GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                    GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.", AccountNoMPKCode."Account No. 4");
                END;

                GenJournalLine.Description := STRSUBSTNO('%1 %2 %3', "Production Settlement Header".Description,
                  "Prod. Settl. Summary Lines"."OBIEKT Dim Value", ProdSettlSummaryLinesDetails."Work Type Code");

                GenJournalLine.INSERT(TRUE);

                CreateDimToProdSetllDetails(GenJournalLine, ProdSettlSummaryLinesDetails);

                GenJournalLine.INIT;
                LineNo += 10000;

                GenJournalLine.INIT;
                GenJournalLine.VALIDATE(GenJournalLine."Journal Template Name", JournalTemplateName);
                GenJournalLine.VALIDATE(GenJournalLine."Journal Batch Name", JournalBatchName);
                GenJournalLine."Line No." := LineNo;

                GenJournalLine.VALIDATE(GenJournalLine."Posting Date", PostingDate);
                GenJournalLine.VALIDATE(GenJournalLine."Document No.", "Production Settlement Header"."No.");
                GenJournalLine.VALIDATE(GenJournalLine."Account Type", GenJournalLine."Account Type"::"G/L Account");
                GenJournalLine.VALIDATE(GenJournalLine."Account No.", AccountNoMPKCode."Account No. 7");
                GenJournalLine.VALIDATE(GenJournalLine.Amount, ProdSettlSummaryLinesDetails."Variable Amount To Post");

                IF "Production Settlement Header"."Account No. (6*)" <> '' THEN BEGIN
                    GenJournalLine.VALIDATE(GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                    GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.", AccountNoMPKCode."Account No. 6");
                END;

                GenJournalLine.Description := STRSUBSTNO('%1 %2 %3', "Production Settlement Header".Description,
                 "Prod. Settl. Summary Lines"."OBIEKT Dim Value", ProdSettlSummaryLinesDetails."Work Type Code");

                GenJournalLine.INSERT(TRUE);

                CreateDimToProdSetllDetails(GenJournalLine, ProdSettlSummaryLinesDetails);
            UNTIL ProdSettlSummaryLinesDetails.NEXT = 0;
    end;

    local procedure GetLineNo(): Integer
    var
        GenJournalLineLast: Record "Gen. Journal Line";
    begin
        GenJournalLineLast.RESET;
        GenJournalLineLast.SETRANGE("Journal Batch Name", JournalBatchName);
        GenJournalLineLast.SETRANGE("Journal Template Name", JournalTemplateName);
        IF GenJournalLineLast.FINDLAST THEN
            EXIT(GenJournalLineLast."Line No.");

        EXIT(0);
    end;

    local procedure CreateDimToProdSetllDetails(var _GenJournalLine: Record "Gen. Journal Line"; _ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines")
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        DimVal: Code[20];
        Create: Boolean;
        Pos: Integer;
    begin
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, _GenJournalLine."Dimension Set ID");

        DefaultDimension.RESET;
        DefaultDimension.SETRANGE("Table ID", DATABASE::"G/L Account");
        DefaultDimension.SETRANGE("No.", _GenJournalLine."Account No.");
        IF DefaultDimension.FINDSET THEN
            REPEAT
                Create := FALSE;
                IF (DefaultDimension."Dimension Code" = 'MPK') THEN BEGIN
                    Create := TRUE;
                    DimVal := _ProdSettlSummaryLines."OBIEKT Dim Value";
                END;

                IF Create THEN BEGIN
                    TempDimensionSetEntry.RESET;
                    TempDimensionSetEntry.SETRANGE("Dimension Code", DefaultDimension."Dimension Code");
                    IF TempDimensionSetEntry.FINDFIRST THEN BEGIN
                        TempDimensionSetEntry.VALIDATE("Dimension Value Code", DimVal);
                        TempDimensionSetEntry.MODIFY;
                    END ELSE BEGIN
                        TempDimensionSetEntry.INIT;
                        TempDimensionSetEntry.VALIDATE("Dimension Code", DefaultDimension."Dimension Code");
                        TempDimensionSetEntry.VALIDATE("Dimension Value Code", DimVal);
                        TempDimensionSetEntry.INSERT;
                    END;
                END;

            UNTIL DefaultDimension.NEXT = 0;

        TempDimensionSetEntry.RESET;

        _GenJournalLine.VALIDATE("Dimension Set ID", DimensionManagement.GetDimensionSetID(TempDimensionSetEntry));
        _GenJournalLine.MODIFY(TRUE);

        GetDimFromWorkType(_GenJournalLine, _ProdSettlSummaryLines, _ProdSettlSummaryLines."Work Type Code");
    end;

    local procedure GetDimFromWorkType(var _GenJournalLine: Record "Gen. Journal Line"; _ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines"; WorkTypeCode: Code[10])
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        DimVal: Code[20];
        Create: Boolean;
        Pos: Integer;
        DefaultDimWorkType: Record "Default Dimension";
    begin
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, _GenJournalLine."Dimension Set ID");

        DefaultDimWorkType.RESET;
        DefaultDimWorkType.SETRANGE("Table ID", DATABASE::"Work Type");
        DefaultDimWorkType.SETRANGE("No.", WorkTypeCode);
        IF DefaultDimWorkType.FINDSET THEN
            REPEAT
                IF DefaultDimension.GET(DATABASE::"G/L Account", _GenJournalLine."Account No.", DefaultDimWorkType."Dimension Code") THEN BEGIN
                    TempDimensionSetEntry.RESET;
                    TempDimensionSetEntry.SETRANGE("Dimension Code", DefaultDimension."Dimension Code");
                    IF TempDimensionSetEntry.FINDFIRST THEN BEGIN
                        TempDimensionSetEntry.VALIDATE("Dimension Value Code", DefaultDimWorkType."Dimension Value Code");
                        TempDimensionSetEntry.MODIFY;
                    END ELSE BEGIN
                        TempDimensionSetEntry.INIT;
                        TempDimensionSetEntry.VALIDATE("Dimension Code", DefaultDimWorkType."Dimension Code");
                        TempDimensionSetEntry.VALIDATE("Dimension Value Code", DefaultDimWorkType."Dimension Value Code");
                        TempDimensionSetEntry.INSERT;
                    END;
                END;
            UNTIL DefaultDimWorkType.NEXT = 0;

        TempDimensionSetEntry.RESET;

        _GenJournalLine.VALIDATE("Dimension Set ID", DimensionManagement.GetDimensionSetID(TempDimensionSetEntry));
        DimensionManagement.UpdateGlobalDimFromDimSetID(_GenJournalLine."Dimension Set ID", _GenJournalLine."Shortcut Dimension 1 Code", _GenJournalLine."Shortcut Dimension 2 Code");
        _GenJournalLine.MODIFY;



    end;
}


