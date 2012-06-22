package uk.ac.ebi.fg.utils.objects;

import uk.ac.ebi.fg.utils.ISimilarityComponent;

public class StaticSimilarityComponent
{
    static private ISimilarityComponent component;

    public StaticSimilarityComponent()
    {}

    static public void setComponent(ISimilarityComponent simComponent)
    {
        component = simComponent;
    }

    static public ISimilarityComponent getComponent()
    {
        return component;
    }
}
