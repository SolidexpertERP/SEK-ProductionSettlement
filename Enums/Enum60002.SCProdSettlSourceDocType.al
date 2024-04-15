enum 60002 "SC Prod. Settl. Src. Doc. Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Payment)
    {
        Caption = 'Płatność';
    }
    value(2; Invoice)
    {
        Caption = 'Faktura';
    }
    value(3; "Credit Memo")
    {
        Caption = 'Faktura korygująca';
    }
    value(4; "Finance Charge Memo")
    {
        Caption = 'Nota odsetkowa';
    }
    value(5; Reminder)
    {
        Caption = 'Monit';
    }
    value(6; Refund)
    {
        Caption = 'Zwrot';
    }
}
