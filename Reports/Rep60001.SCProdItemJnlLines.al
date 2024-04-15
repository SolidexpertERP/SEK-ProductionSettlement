report 60001 "SC Prod. Item Jnl. Lines"
{
    ProcessingOnly = true;
    Caption = 'Generowanie dziennika zapasów';

    dataset
    {
        dataitem("Prod. Settl. Summary Lines"; "SC Prod. Settl. Summary Lines")
        {
            DataItemTableView = SORTING("Document No.", "Line Type", "OBIEKT Dim Value", "Line No.")
                                ORDER(Ascending)
                                WHERE("Line Type" = CONST("General Sum"),
                                      "OBIEKT Dim Value" = FILTER(<> ''));

            trigger OnAfterGetRecord()
            var
                FixedQty: Decimal;
                VariableQty: Decimal;
            begin
                "Prod. Settl. Summary Lines".CALCFIELDS("Fixed Cost Item", "Variable Cost Item");

                GenerateItemVariantCode;


                CLEAR(VariableQty);
                IF UndoSettlement THEN
                    VariableQty := "Prod. Settl. Summary Lines"."Real Hours"
                ELSE
                    VariableQty := "Prod. Settl. Summary Lines".CalculateVariableTimeToPost;

                IF VariableQty > 0 THEN BEGIN
                    LineNo += 10000;
                    ItemJournalLine.INIT;
                    ItemJournalLine."Journal Template Name" := ItemJournalTemplate;
                    ItemJournalLine."Journal Batch Name" := ItemJournalBatch;
                    ItemJournalLine."Line No." := LineNo;
                    ItemJournalLine.VALIDATE(ItemJournalLine."Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");

                    ItemJournalLine.VALIDATE(ItemJournalLine."Posting Date", PostingDate);
                    ItemJournalLine.VALIDATE(ItemJournalLine."Document No.", "Prod. Settl. Summary Lines"."Document No.");

                    ItemJournalLine.VALIDATE(ItemJournalLine."Item No.", "Prod. Settl. Summary Lines"."Variable Cost Item");
                    ItemJournalLine.VALIDATE(ItemJournalLine."Variant Code", "Prod. Settl. Summary Lines"."Variant Code");

                    ItemJournalLine.VALIDATE(ItemJournalLine."Location Code", 'ZD.PROD');
                    IF UndoSettlement THEN
                        VariableQty := -VariableQty;
                    ItemJournalLine.VALIDATE(ItemJournalLine.Quantity, VariableQty);

                    ItemJournalLine.VALIDATE(ItemJournalLine."Unit Amount", "Prod. Settl. Summary Lines".CalculateUnitVariableCost);
                    //IF "Unit Amount" < 0 THEN
                    //VALIDATE("G/L Correction", TRUE);
                    ItemJournalLine.INSERT(TRUE);
                END;
            end;

            trigger OnPreDataItem()
            begin
                CleanJournal;

                cnt := "Prod. Settl. Summary Lines".COUNT;
                CLEAR(LineNo);
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
                        TableRelation = "Item Journal Template".Name WHERE(Type = CONST(Item));
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
                            ItemJnlBatch.SETRANGE("Template Type", ItemJnlBatch."Template Type"::Item);
                            ItemJournalBatches.LOOKUPMODE(TRUE);
                            ItemJournalBatches.SETTABLEVIEW(ItemJnlBatch);
                            IF ItemJournalBatches.RUNMODAL = ACTION::LookupOK THEN BEGIN
                                ItemJournalBatches.GETRECORD(ItemJnlBatch);
                                ItemJournalBatch := ItemJnlBatch.Name;
                            END;
                        end;
                    }
                    field(UndoSettlement; UndoSettlement)
                    {
                        Caption = 'Wycofaj zaks. zapisy';
                        ApplicationArea = all;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            UndoSettlement := FALSE;
        end;
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
        UndoSettlement: Boolean;

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
          ItemVariant.Description := Item.Description + ' ' + "Prod. Settl. Summary Lines"."Variant Code";
          ItemVariant."Description 2" := Item."Description 2";
          ItemVariant.INSERT;
        END;*/

        Item.GET("Prod. Settl. Summary Lines"."Variable Cost Item");
        IF NOT ItemVariant.GET(Item."No.", "Prod. Settl. Summary Lines"."Variant Code") THEN BEGIN
            ItemVariant.INIT;
            ItemVariant."Item No." := Item."No.";
            ItemVariant.Code := "Prod. Settl. Summary Lines"."Variant Code";
            ItemVariant.Description := Item.Description + ' ' + "Prod. Settl. Summary Lines"."Variant Code";
            ItemVariant."Description 2" := Item."Description 2";
            ItemVariant.INSERT;
        END;

    end;
}


