enum 60005 "SC Fixed/Variable Costs"
{
    Caption = 'Koszty stałe/zmienne';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Fixed")
    {
        Caption = 'Stałe';
    }
    value(2; Variable)
    {
        Caption = 'Zmienne';
    }
}
