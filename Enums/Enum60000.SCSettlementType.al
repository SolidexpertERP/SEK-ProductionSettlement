enum 60000 "SC Settlement Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Production)
    {
        Caption = 'Produkcja';
    }
    value(2; "Assembly")
    {
        Caption = 'Kompletacja';
    }
    value(3; Job)
    {
        Caption = 'Zlecenie';
    }
}
