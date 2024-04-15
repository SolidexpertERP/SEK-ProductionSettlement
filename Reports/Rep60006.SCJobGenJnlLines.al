report 60006 "SC Job Gen. Jnl. Lines"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Prod. Settl. Summary Lines"; "SC Prod. Settl. Summary Lines")
        {
            DataItemTableView = SORTING("Document No.", "Production Order No.", "Prod. Order Line No.", "Line Type", "OBIEKT Dim Value")
                                ORDER(Ascending)
                                WHERE("Line Type" = CONST("Detailed Dest Sum"),
                                      "Variable Amount To Post" = FILTER(<> 0));

            trigger OnAfterGetRecord()
            var
                ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
                Qty: Decimal;
                Job: Record "Job";
                WorkType: Record "Work Type";
                PostJobCosts: Boolean;
            begin
                //AccountNo := '630-01';
                //BalAccountNo := '490-01';
                CLEAR(AccountNo);
                CLEAR(BalAccountNo);

                IF ROUND("Prod. Settl. Summary Lines"."Variable Amount To Post") = ROUND("Prod. Settl. Summary Lines"."General Cost - Sum") THEN
                    CurrReport.SKIP;

                //Job.GET("Prod. Settl. Summary Lines"."Job No.");

                /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
                /*
                IF WorkType.GET("Prod. Settl. Summary Lines"."Work Type Code") THEN BEGIN
                    IF WorkType."Account No." <> '' THEN
                        AccountNo := WorkType."Account No.";

                    IF WorkType."Bal. Account No." <> '' THEN
                        BalAccountNo := WorkType."Bal. Account No.";

                    PostJobCosts := WorkType."Post Job Costs";
                END;
                */

                IF (AccountNo = '') OR (BalAccountNo = '') THEN
                    CurrReport.SKIP;

                i += 1;
                Window.UPDATE(1, ROUND(i / cnt * 10000, 1, '='));


                LineNo += 10000;

                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := GenJournalTemplate;
                GenJournalLine."Journal Batch Name" := GenJournalBatch;
                GenJournalLine."Line No." := LineNo;

                GenJournalLine.VALIDATE(GenJournalLine."Posting Date", PostingDate);
                GenJournalLine.VALIDATE(GenJournalLine."Document No.", "Prod. Settl. Summary Lines"."Document No.");

                GenJournalLine.VALIDATE(GenJournalLine."Account No.", AccountNo);
                GenJournalLine.VALIDATE(GenJournalLine.Amount, "Prod. Settl. Summary Lines"."Variable Amount To Post");
                IF PostJobCosts THEN
                    GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.", BalAccountNo);

                IF PostJobCosts THEN BEGIN
                    GenJournalLine.VALIDATE(GenJournalLine."Job No.", "Prod. Settl. Summary Lines"."Job No.");
                    GenJournalLine.VALIDATE(GenJournalLine."Job Task No.", "Prod. Settl. Summary Lines"."Job Task No.");
                END;

                ManageDimensions(GenJournalLine, PostJobCosts, 1);

                GenJournalLine.INSERT(TRUE);

                IF NOT PostJobCosts THEN BEGIN
                    LineNo += 10000;

                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := GenJournalTemplate;
                    GenJournalLine."Journal Batch Name" := GenJournalBatch;
                    GenJournalLine."Line No." := LineNo;

                    GenJournalLine.VALIDATE(GenJournalLine."Posting Date", PostingDate);
                    GenJournalLine.VALIDATE(GenJournalLine."Document No.", "Prod. Settl. Summary Lines"."Document No.");

                    GenJournalLine.VALIDATE(GenJournalLine."Account No.", AccountNo);
                    GenJournalLine.VALIDATE(GenJournalLine.Amount, -"Prod. Settl. Summary Lines"."Variable Amount To Post");

                    ManageDimensions(GenJournalLine, PostJobCosts, 2);

                    GenJournalLine.INSERT(TRUE);
                END;
            end;

            trigger OnPostDataItem()
            begin
                Window.CLOSE;
            end;

            trigger OnPreDataItem()
            begin
                CleanJournal;
                Window.OPEN('Trwa generowanie dziennika @1@@@@@@@@@@');

                cnt := "Prod. Settl. Summary Lines".COUNT;
                CLEAR(LineNo);
                CLEAR(i);

                TempDimensionSetEntry.DELETEALL;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Ustawienia)
                {
                    Caption = 'Ustawienia';
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = all;
                        Caption = 'Data księgowania';
                    }
                    field(GenJournalTemplate; GenJournalTemplate)
                    {
                        ApplicationArea = all;
                        Caption = 'Szablon dziennika';
                        TableRelation = "Gen. Journal Template".Name WHERE(Type = CONST(Jobs));
                    }
                    field(GenJournalBatch; GenJournalBatch)
                    {
                        ApplicationArea = all;
                        Caption = 'Instancja dziennika';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            _GenJournalBatch: Record "Gen. Journal Batch";
                            GeneralJournalBatches: Page "General Journal Batches";
                        begin
                            IF GenJournalTemplate = '' THEN
                                ERROR('Najpierw wybierz szablon dziennika głównego');

                            _GenJournalBatch.RESET;
                            _GenJournalBatch.SETRANGE("Journal Template Name", GenJournalTemplate);
                            GeneralJournalBatches.LOOKUPMODE(TRUE);
                            GeneralJournalBatches.SETTABLEVIEW(_GenJournalBatch);
                            IF GeneralJournalBatches.RUNMODAL = ACTION::LookupOK THEN BEGIN
                                GeneralJournalBatches.GETRECORD(_GenJournalBatch);
                                GenJournalBatch := _GenJournalBatch.Name;
                            END;
                        end;
                    }
                }
            }
        }

    }

    labels
    {
    }

    trigger OnPostReport()
    var
        JobJournal: Page "Job G/L Journal";
        JournalMgt: Codeunit "Batch Processing Mgt. Handler";
    begin
        //_GenJournalBatch.GET(GenJournalTemplate, GenJournalBatch);
        GenJournalLine.RESET;
        PAGE.RUN(PAGE::"Job G/L Journal", GenJournalLine);
    end;

    trigger OnPreReport()
    begin
        IF (GenJournalTemplate = '') OR (GenJournalBatch = '') THEN
            ERROR('Należy wybrać dziennik i jego instancję');

        IF PostingDate = 0D THEN
            ERROR('Wybierz datę księgowania');
    end;

    var
        GenJournalTemplate: Code[10];
        GenJournalBatch: Code[10];
        GenJournalLine: Record "Gen. Journal Line";
        PostingDate: Date;
        cnt: Integer;
        i: Integer;
        LineNo: Integer;
        Window: Dialog;
        Item: Record "Item";
        TempItemJournalLine: Record "Item Journal Line" temporary;
        AccountNo: Code[20];
        BalAccountNo: Code[20];
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit "DimensionManagement";
        DefaultDimension: Record "Default Dimension";

    local procedure CleanJournal()
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", GenJournalTemplate);
        GenJournalLine.SETRANGE("Journal Batch Name", GenJournalBatch);
        IF GenJournalLine.COUNT > 0 THEN BEGIN
            IF CONFIRM('W dzienniku głównym znajdują się rekordy. Przed kontynuacją należy je usunąć. Czy chcesz to zrobić teraz?') THEN BEGIN
                Window.OPEN('Trwa usuwanie dziennika...');
                GenJournalLine.DELETEALL(TRUE);
                Window.CLOSE;
            END ELSE
                ERROR('Usuń wiersze ręcznie');
        END;
    end;

    local procedure CheckQuantity()
    begin
        IF "Prod. Settl. Summary Lines".CalculateTimeToConsum = 0 THEN
            CurrReport.SKIP;
    end;

    local procedure FindItemLedgerEntry(var ItemJournalLine: Record "Item Journal Line")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.RESET;
        ItemLedgerEntry.SETRANGE("Document No.", ItemJournalLine."Document No.");
        ItemLedgerEntry.SETRANGE("Item No.", ItemJournalLine."Item No.");
        ItemLedgerEntry.SETRANGE("Entry Type", ItemJournalLine."Entry Type"::"Assembly Output");
        ItemLedgerEntry.SETRANGE(Positive, TRUE);
        ItemLedgerEntry.FINDLAST;
    end;

    local procedure ManageDimensions(var GenJournalLine: Record "Gen. Journal Line"; PostPerJob: Boolean; RowNo: Integer)
    var
        cnt: Integer;
    begin
        TempDimensionSetEntry.DELETEALL;

        IF "Prod. Settl. Summary Lines"."Job Planning Line No." <> 0 THEN
            GetDimFromJobPlanningLine(GenJournalLine);

        IF RowNo = 1 THEN BEGIN
            GetDimFromResourceGroup(GenJournalLine);
            GetDimFromWorkType(GenJournalLine);
            GetDimFromJobTask(GenJournalLine);
        END ELSE
            IF RowNo = 2 THEN BEGIN
                GetDimFromWorkType(GenJournalLine);
                GetDimFromResourceGroup(GenJournalLine);
                GetDimFromJobTask(GenJournalLine);
            END;

        GetDimFromGLAccount(GenJournalLine);

        CleanTempDimSetEntryFromUnusedDimensions;
        GenJournalLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);

        DimensionManagement.UpdateGlobalDimFromDimSetID(GenJournalLine."Dimension Set ID", GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
    end;

    local procedure GetDimFromJobPlanningLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.GET("Prod. Settl. Summary Lines"."Job No.", "Prod. Settl. Summary Lines"."Job Task No.", "Prod. Settl. Summary Lines"."Job Planning Line No.");

        /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
        /*
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, JobPlanningLine."Dimension Set ID");
        */

        TempDimensionSetEntry.RESET;
    end;

    local procedure GetDimFromResourceGroup(var GenJournalLine: Record "Gen. Journal Line")
    begin
        DefaultDimension.RESET;
        DefaultDimension.SETRANGE("Table ID", DATABASE::"Resource Group");
        DefaultDimension.SETRANGE("No.", "Prod. Settl. Summary Lines"."OBIEKT Dim Value");
        IF DefaultDimension.FINDSET THEN
            REPEAT
                TempDimensionSetEntry.RESET;
                TempDimensionSetEntry.SETRANGE("Dimension Code", DefaultDimension."Dimension Code");
                IF TempDimensionSetEntry.FINDFIRST THEN BEGIN
                    TempDimensionSetEntry.VALIDATE("Dimension Value Code", DefaultDimension."Dimension Value Code");
                    TempDimensionSetEntry.MODIFY;
                END ELSE BEGIN
                    TempDimensionSetEntry.INIT;
                    TempDimensionSetEntry.VALIDATE("Dimension Code", DefaultDimension."Dimension Code");
                    TempDimensionSetEntry.VALIDATE("Dimension Value Code", DefaultDimension."Dimension Value Code");
                    TempDimensionSetEntry.INSERT;
                END;
            UNTIL DefaultDimension.NEXT = 0;

        TempDimensionSetEntry.RESET;
    end;

    local procedure GetDimFromWorkType(var GenJournalLine: Record "Gen. Journal Line")
    begin
        DefaultDimension.RESET;
        DefaultDimension.SETRANGE("Table ID", DATABASE::"Work Type");
        DefaultDimension.SETRANGE("No.", "Prod. Settl. Summary Lines"."Work Type Code");
        IF DefaultDimension.FINDSET THEN
            REPEAT
                TempDimensionSetEntry.RESET;
                TempDimensionSetEntry.SETRANGE("Dimension Code", DefaultDimension."Dimension Code");
                IF TempDimensionSetEntry.FINDFIRST THEN BEGIN
                    TempDimensionSetEntry.VALIDATE("Dimension Value Code", DefaultDimension."Dimension Value Code");
                    TempDimensionSetEntry.MODIFY;
                END ELSE BEGIN
                    TempDimensionSetEntry.INIT;
                    TempDimensionSetEntry.VALIDATE("Dimension Code", DefaultDimension."Dimension Code");
                    TempDimensionSetEntry.VALIDATE("Dimension Value Code", DefaultDimension."Dimension Value Code");
                    TempDimensionSetEntry.INSERT;
                END;
            UNTIL DefaultDimension.NEXT = 0;

        TempDimensionSetEntry.RESET;
    end;

    local procedure GetDimFromJobTask(var GenJournalLine: Record "Gen. Journal Line")
    var
        JobTaskDimension: Record "Job Task Dimension";
    begin
        IF "Prod. Settl. Summary Lines"."Job No." = '' THEN
            EXIT;


        JobTaskDimension.RESET;
        JobTaskDimension.SETRANGE("Job No.", "Prod. Settl. Summary Lines"."Job No.");
        JobTaskDimension.SETRANGE("Job Task No.", "Prod. Settl. Summary Lines"."Job Task No.");
        IF JobTaskDimension.FINDSET THEN
            REPEAT
                TempDimensionSetEntry.RESET;
                TempDimensionSetEntry.SETRANGE("Dimension Code", JobTaskDimension."Dimension Code");
                IF TempDimensionSetEntry.FINDFIRST THEN BEGIN
                    TempDimensionSetEntry.VALIDATE("Dimension Value Code", JobTaskDimension."Dimension Value Code");
                    TempDimensionSetEntry.MODIFY;
                END ELSE BEGIN
                    TempDimensionSetEntry.INIT;
                    TempDimensionSetEntry.VALIDATE("Dimension Code", JobTaskDimension."Dimension Code");
                    TempDimensionSetEntry.VALIDATE("Dimension Value Code", JobTaskDimension."Dimension Value Code");
                    TempDimensionSetEntry.INSERT;
                END;
            UNTIL JobTaskDimension.NEXT = 0;

        TempDimensionSetEntry.RESET;
    end;

    local procedure GetDimFromGLAccount(var GenJournalLine: Record "Gen. Journal Line")
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.RESET;
        DefaultDimension.SETRANGE("Table ID", DATABASE::"G/L Account");
        DefaultDimension.SETRANGE("No.", GenJournalLine."Account No.");
        DefaultDimension.SETFILTER("Dimension Value Code", '<>%1', '');
        IF DefaultDimension.FINDSET THEN
            REPEAT
                TempDimensionSetEntry.RESET;
                TempDimensionSetEntry.SETRANGE("Dimension Code", DefaultDimension."Dimension Code");
                IF TempDimensionSetEntry.FINDFIRST THEN BEGIN
                    TempDimensionSetEntry.VALIDATE("Dimension Value Code", DefaultDimension."Dimension Value Code");
                    TempDimensionSetEntry.MODIFY;
                END ELSE BEGIN
                    TempDimensionSetEntry.INIT;
                    TempDimensionSetEntry.VALIDATE("Dimension Code", DefaultDimension."Dimension Code");
                    TempDimensionSetEntry.VALIDATE("Dimension Value Code", DefaultDimension."Dimension Value Code");
                    TempDimensionSetEntry.INSERT;
                END;
            UNTIL DefaultDimension.NEXT = 0;

        TempDimensionSetEntry.RESET;
    end;

    local procedure CleanTempDimSetEntryFromUnusedDimensions()
    begin
        TempDimensionSetEntry.RESET;

        DefaultDimension.RESET;
        DefaultDimension.SETRANGE("Table ID", DATABASE::"G/L Account");
        DefaultDimension.SETRANGE("No.", GenJournalLine."Account No.");
        IF DefaultDimension.COUNT = 0 THEN
            EXIT;


        IF TempDimensionSetEntry.FINDSET THEN
            REPEAT
                IF NOT DefaultDimension.GET(DATABASE::"G/L Account", GenJournalLine."Account No.", TempDimensionSetEntry."Dimension Code") THEN
                    TempDimensionSetEntry.DELETE;
            UNTIL TempDimensionSetEntry.NEXT = 0;

        TempDimensionSetEntry.RESET;
    end;
}

