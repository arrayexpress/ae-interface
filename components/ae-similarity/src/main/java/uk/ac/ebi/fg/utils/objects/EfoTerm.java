package uk.ac.ebi.fg.utils.objects;

public class EfoTerm implements Comparable
{
    private String uri;
    private String textValue;

    public EfoTerm(String uri, String textValue)
    {
        this.uri = uri;
        this.textValue = textValue;
    }

    public String getUri()
    {
        return uri;
    }

    public String getTextValue()
    {
        return textValue;
    }

    public int compareTo(Object object)
    {
        EfoTerm term = (EfoTerm) object;
        return uri.compareTo(term.getUri());
    }

    @Override
    public boolean equals(Object object)
    {
        if ( this == object ) return true;
        if ( null == object || getClass() != object.getClass() ) return false;
        EfoTerm efoTerm = (EfoTerm) object;

        if ( uri.equals(efoTerm.getUri()) )
            return true;
        return false;
    }

    @Override
    public int hashCode()
    {
        return uri.hashCode();
    }
}
