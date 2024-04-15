enum 60004 "SC Prod. Settl. Line Type"
{
    Caption = 'Typ wiersza rozliczenia produkcji';
    Extensible = true;

    value(0; "Detailed Source Sum")
    {
        Caption = 'Suma szczeg. zap. źródłowych';
    }
    value(1; "Detailed Dest Sum")
    {
        Caption = 'Suma szczeg. zap. zd. prod.';
    }
    value(2; "General Sum")
    {
        Caption = 'Suma ogólna';
    }
}
