report 60004 "SC Asb. Settl. Revaluation Lin"
{
    ProcessingOnly = true;
    Caption = 'Generowanie dziennika przeszacowań';
    dataset
    {
        dataitem("Prod. Settl. Summary Lines"; "SC Prod. Settl. Summary Lines")
        {
            DataItemTableView = SORTING("Document No.", "Production Order No.", "Prod. Order Line No.", "Line Type", "OBIEKT Dim Value")
                                ORDER(Ascending)
                                WHERE("Line Type" = CONST("Detailed Dest Sum"),
                                      "OBIEKT Dim Value" = FILTER(<> ''));

            trigger OnAfterGetRecord()
            var
                ProdSettlSummaryLines: Record "SC Prod.Settlement Header";
                Qty: Decimal;
            begin
                "Prod. Settl. Summary Lines".CALCFIELDS("Assembly Item No.", "Posted Asb. Real Cost", "Posted Assembly Qty", "Item Ledger Entry No.", "Posted Costs");

                CheckQuantity;

                i += 1;
                Window.UPDATE(1, ROUND(i / cnt * 10000, 1, '='));

                ItemJournalLine.RESET;
                //SETRANGE("Document No.", "Prod. Settl. Summary Lines"."Production Order No.");
                //SETRANGE("Item No.", "Prod. Settl. Summary Lines"."Assembly Item No.");
                ItemJournalLine.SETRANGE(ItemJournalLine."Journal Template Name", ItemJournalTemplate);
                ItemJournalLine.SETRANGE(ItemJournalLine."Journal Batch Name", ItemJournalBatch);
                ItemJournalLine.SETRANGE(ItemJournalLine."Applies-to Entry", "Prod. Settl. Summary Lines"."Item Ledger Entry No.");
                IF ItemJournalLine.FINDFIRST THEN BEGIN
                    ItemJournalLine.VALIDATE(ItemJournalLine."Inventory Value (Revalued)", ItemJournalLine."Inventory Value (Revalued)" + "Prod. Settl. Summary Lines"."Fixed Amount To Post");
                    ItemJournalLine.MODIFY;
                END ELSE BEGIN

                    LineNo += 10000;

                    ItemJournalLine.INIT;
                    ItemJournalLine."Journal Template Name" := ItemJournalTemplate;
                    ItemJournalLine."Journal Batch Name" := ItemJournalBatch;
                    ItemJournalLine."Line No." := LineNo;
                    ItemJournalLine.SetUpNewLine(ItemJournalLine);

                    ItemJournalLine.VALIDATE(ItemJournalLine."Posting Date", PostingDate);
                    ItemJournalLine.VALIDATE(ItemJournalLine."Document No.", "Prod. Settl. Summary Lines"."Document No.");

                    ItemJournalLine.VALIDATE(ItemJournalLine."Item No.", "Prod. Settl. Summary Lines"."Assembly Item No.");
                    //VALIDATE(Quantity, "Prod. Settl. Summary Lines"."Posted Assembly Qty");
                    //FindItemLedgerEntry(ItemJournalLine);
                    ItemJournalLine.VALIDATE("Applies-to Entry", "Prod. Settl. Summary Lines"."Item Ledger Entry No.");

                    ItemJournalLine.VALIDATE(ItemJournalLine."Inventory Value (Revalued)", ("Prod. Settl. Summary Lines"."Fixed Amount To Post" + "Prod. Settl. Summary Lines"."Posted Asb. Real Cost") - "Prod. Settl. Summary Lines"."Posted Costs");

                    ItemJournalLine.INSERT(TRUE);
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
                    field(ItemJournalTemplate; ItemJournalTemplate)
                    {
                        ApplicationArea = all;
                        Caption = 'Szablon dziennika';
                        TableRelation = "Item Journal Template".Name WHERE(Type = CONST(Revaluation));
                    }
                    field(ItemJournalBatch; ItemJournalBatch)
                    {
                        ApplicationArea = all;
                        Caption = 'Instancja dziennika';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            ItemJnlBatch: Record "Item Journal Batch";
                            ItemJournalBatches: Page "Item Journal Batches";
                        begin
                            IF ItemJournalTemplate = '' THEN
                                ERROR('Najpierw wybierz szablon dziennika zapasów');

                            ItemJnlBatch.RESET;
                            ItemJnlBatch.SETRANGE("Journal Template Name", ItemJournalTemplate);
                            ItemJournalBatches.LOOKUPMODE(TRUE);
                            ItemJournalBatches.SETTABLEVIEW(ItemJnlBatch);
                            Commit();
                            IF ItemJournalBatches.RUNMODAL = ACTION::LookupOK THEN BEGIN
                                ItemJournalBatches.GETRECORD(ItemJnlBatch);
                                ItemJournalBatch := ItemJnlBatch.Name;
                            END;
                        end;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        _ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlManagement: Codeunit ItemJnlManagement;
    begin
        _ItemJournalBatch.Get(ItemJournalTemplate, ItemJournalBatch);
        ItemJnlManagement.TemplateSelectionFromBatch(_ItemJournalBatch);
    end;

    trigger OnPreReport()
    begin
        IF (ItemJournalTemplate = '') OR (ItemJournalBatch = '') THEN
            ERROR('Należy wybrać dziennik i jego instancję');

        IF PostingDate = 0D THEN
            ERROR('Wybierz datę księgowania');
    end;

    var
        ItemJournalTemplate: Code[10];
        ItemJournalBatch: Code[10];
        ItemJournalLine: Record "Item Journal Line";
        PostingDate: Date;
        cnt: Integer;
        i: Integer;
        LineNo: Integer;
        Window: Dialog;
        Item: Record "Item";
        TempItemJournalLine: Record "Item Journal Line" temporary;

    local procedure CleanJournal()
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ItemJournalLine.RESET;
        ItemJournalLine.SETRANGE("Journal Template Name", ItemJournalTemplate);
        ItemJournalLine.SETRANGE("Journal Batch Name", ItemJournalBatch);
        IF ItemJournalLine.COUNT > 0 THEN BEGIN
            IF CONFIRM('W dzienniku zapasów znajdują się rekordy. Przed kontynuacją należy je usunąć. Czy chcesz to zrobić teraz?') THEN BEGIN
                ReservationEntry.RESET;
                ReservationEntry.SETRANGE("Source ID", ItemJournalTemplate);
                ReservationEntry.SETRANGE("Source Batch Name", ItemJournalBatch);
                ReservationEntry.DELETEALL(FALSE);
                //ItemJournalLine.SetSilentDelete;
                ItemJournalLine.DELETEALL(TRUE);
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
}

