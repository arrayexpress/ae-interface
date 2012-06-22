package uk.ac.ebi.fg.utils.objects;

import uk.ac.ebi.arrayexpress.utils.efo.IEFO;

public class EFO {

    private static IEFO efo;

    public EFO()
    {
    }

    public static void setEfo( IEFO newEfo )
    {
        efo = newEfo;
    }

    public static IEFO getEfo()
    {
        return efo;
    }

}
