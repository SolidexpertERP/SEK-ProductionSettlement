report 60003 "SC Prod. Settl. Reval. Lines"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Prod. Settl. Summary Lines"; "SC Prod. Settl. Summary Lines")
        {
            DataItemTableView = SORTING("Document No.", "Production Order No.", "Prod. Order Line No.", "Line Type", "OBIEKT Dim Value")
                                ORDER(Ascending)
                                WHERE("Line Type" = CONST("General Sum"),
                                      "OBIEKT Dim Value" = FILTER(<> ''));

            trigger OnAfterGetRecord()
            var
                ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
                Qty: Decimal;
                ProductionOrder: Record "Production Order";
                ItemLedgerEntry: Record "Item Ledger Entry";
                ValueEntry: Record "Value Entry";
            begin
                "Prod. Settl. Summary Lines".CALCFIELDS("Fixed Cost Item", "Variable Cost Item");

                //GenerateItemVariantCode;
                CheckAmount;

                ItemLedgerEntry.RESET;
                ItemLedgerEntry.SETRANGE("Item No.", "Prod. Settl. Summary Lines"."Variable Cost Item");
                ItemLedgerEntry.SETRANGE("Variant Code", "Prod. Settl. Summary Lines"."Variant Code");
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Positive Adjmt.");
                ItemLedgerEntry.FindLast();

                ValueEntry.RESET;
                ValueEntry.SETRANGE("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                ValueEntry.FINDFIRST;


                i += 1;
                Window.UPDATE(1, ROUND(i / cnt * 10000, 1, '='));
                LineNo += 10000;

                ItemJournalLine.INIT;
                ItemJournalLine."Journal Template Name" := ItemJournalTemplate;
                ItemJournalLine."Journal Batch Name" := ItemJournalBatch;
                ItemJournalLine."Line No." := LineNo;
                //VALIDATE("Entry Type", "Entry Type"::Consumption);
                ItemJournalLine.VALIDATE(ItemJournalLine."Value Entry Type", ItemJournalLine."Value Entry Type"::Revaluation);

                ItemJournalLine.VALIDATE(ItemJournalLine."Posting Date", PostingDate);
                ItemJournalLine.VALIDATE(ItemJournalLine."Document No.", "Prod. Settl. Summary Lines"."Document No.");
                //VALIDATE("Order No.", "Prod. Settl. Summary Lines"."Production Order No.");
                //VALIDATE("Order Line No.", "Prod. Settl. Summary Lines"."Prod. Order Line No.");
                ItemJournalLine.VALIDATE(ItemJournalLine."Item No.", "Prod. Settl. Summary Lines"."Variable Cost Item");
                ItemJournalLine.VALIDATE(ItemJournalLine."Applies-to Entry", ItemLedgerEntry."Entry No.");
                ItemJournalLine.VALIDATE(ItemJournalLine."Inventory Value (Revalued)", ItemJournalLine."Inventory Value (Revalued)" + "Prod. Settl. Summary Lines".CalculateProdAmountToPost);

                ItemJournalLine.VALIDATE(ItemJournalLine."Gen. Bus. Posting Group", ValueEntry."Gen. Bus. Posting Group");
                //VALIDATE("Variant Code", "Prod. Settl. Summary Lines"."Variant Code");
                // VALIDATE("Location Code", 'ZD.PROD');
                //VALIDATE(Quantity, "Prod. Settl. Summary Lines".CalculateTimeToConsum);
                /*ProdSettlSummaryLines.RESET;
                ProdSettlSummaryLines.SETRANGE("Document No.", "Prod. Settl. Summary Lines"."Document No.");
                ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
                ProdSettlSummaryLines.SETRANGE("OBIEKT Dim Value", "Prod. Settl. Summary Lines"."OBIEKT Dim Value");
                ProdSettlSummaryLines.FINDFIRST;*/
                //VALIDATE("Unit Amount", ProdSettlSummaryLines.CalculateUnitVariableCost);
                /*IF "Unit Amount" < 0 THEN
                  VALIDATE("G/L Correction", TRUE);*/
                ItemJournalLine.INSERT(TRUE);

            end;

            trigger OnPostDataItem()
            begin
                Window.CLOSE;

                IF err > 0 THEN BEGIN
                    OrderNo := COPYSTR(OrderNo, 1, STRLEN(OrderNo) - 1);
                    MESSAGE('Nie wszystkie zapisy zostały przeniesione do Dziennika Zużycia z uwagi na pozamykane zlecenie. Zlecenia pominięte: %1', OrderNo);
                END;
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
        err: Integer;
        OrderNo: Text;
        ProductionSettlementHeader: Record "SC Prod.Settlement Header";

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

    local procedure GenerateItemVariantCode()
    var
        ItemVariant: Record "Item Variant";
        Item: Record "Item";
    begin
        /*Item.GET("Prod. Settl. Summary Lines"."Fixed Cost Item");
        IF NOT ItemVariant.GET(Item."No.", "Prod. Settl. Summary Lines"."Variant Code") THEN BEGIN
          ItemVariant.INIT;
          ItemVariant."Item No." := Item."No.";
          ItemVariant.Code := "Prod. Settl. Summary Lines"."Variant Code";
          ItemVariant.Description := Item.Description;
          ItemVariant."Description 2" := Item."Description 2";
          ItemVariant.INSERT;
        END;
        */
        Item.GET("Prod. Settl. Summary Lines"."Variable Cost Item");
        IF NOT ItemVariant.GET(Item."No.", "Prod. Settl. Summary Lines"."Variant Code") THEN BEGIN
            ItemVariant.INIT;
            ItemVariant."Item No." := Item."No.";
            ItemVariant.Code := "Prod. Settl. Summary Lines"."Variant Code";
            ItemVariant.Description := Item.Description;
            ItemVariant."Description 2" := Item."Description 2";
            ItemVariant.INSERT;
        END;

    end;

    local procedure CheckAmount()
    begin
        IF "Prod. Settl. Summary Lines".CalculateProdAmountToPost = 0 THEN
            CurrReport.SKIP;
    end;
}


