page 60006 "SC Production Settl. Dialog"
{
    PageType = StandardDialog;
    Caption = 'Utwórz nowy dokument rozliczenia';
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field(Month; NewMonth)
            {
                Caption = 'Miesiąc';
                ApplicationArea = all;
            }
            field(Year; NewYear)
            {
                Caption = 'Rok';
                ApplicationArea = all;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        NewMonth := DATE2DMY(TODAY, 2);
        NewYear := DATE2DMY(TODAY, 3);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ProductionSettlementCard: Page "SC Production Settlement Card";
        AssemblySettlementCard: Page "SC Assembly Settlement Card";
        JobSettlementCard: Page "SC Job Settlement Card";
    begin
        IF CloseAction IN [ACTION::LookupOK, ACTION::OK] THEN BEGIN

            IF (NewMonth = 0) OR (NewYear = 0) THEN
                ERROR('Uzupełnij wszystkie pola!');

            ProductionSettlementHeader.VALIDATE(Month, NewMonth);
            ProductionSettlementHeader.VALIDATE(Year, NewYear);
            ProductionSettlementHeader.INSERT(TRUE);

        END;
    end;

    var
        ProductionSettlementHeader: Record "SC Prod.Settlement Header";
        NewMonth: Integer;
        NewYear: Integer;

    procedure InitPage(_ProductionSettlementHeader: Record "SC Prod.Settlement Header"; _SettlementType: enum "SC Settlement Type")
    begin
        ProductionSettlementHeader.INIT;
        ProductionSettlementHeader."Document Date" := TODAY;
        ProductionSettlementHeader."User Name" := USERID;
        ProductionSettlementHeader.Description := _ProductionSettlementHeader.Description;
        ProductionSettlementHeader."Settlement Type" := _SettlementType;
        ProductionSettlementHeader."Account No. (6*)" := _ProductionSettlementHeader."Account No. (6*)";
        ProductionSettlementHeader."Account No. (4*)" := _ProductionSettlementHeader."Account No. (4*)";
        ProductionSettlementHeader."PROJEKT Dim Filter" := _ProductionSettlementHeader."PROJEKT Dim Filter";
        ProductionSettlementHeader."MKP Dim Filter" := _ProductionSettlementHeader."MKP Dim Filter";
        ProductionSettlementHeader."Account No. (7*)" := _ProductionSettlementHeader."Account No. (7*)";
        ProductionSettlementHeader."KALKULACJA Dim Filter" := _ProductionSettlementHeader."KALKULACJA Dim Filter";
        ProductionSettlementHeader."Variable Cost Item" := _ProductionSettlementHeader."Variable Cost Item";
        ProductionSettlementHeader."Variable Costs Dim Value" := _ProductionSettlementHeader."Variable Costs Dim Value";
        ProductionSettlementHeader."Fixed Cost Item" := _ProductionSettlementHeader."Fixed Cost Item";
        ProductionSettlementHeader."Fixed Costs Dim Value" := _ProductionSettlementHeader."Fixed Costs Dim Value";
        ProductionSettlementHeader."G/L Account Filter" := _ProductionSettlementHeader."G/L Account Filter";
    end;

    procedure GetRec(var _ProductionSettlementHeader: Record "SC Prod.Settlement Header")
    begin
        _ProductionSettlementHeader := ProductionSettlementHeader;
    end;
}

