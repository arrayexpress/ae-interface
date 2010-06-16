package uk.ac.ebi.arrayexpress.components;

/**
 * Created by IntelliJ IDEA.
 * User: nataliyasklyar
 * Date: Jun 16, 2010
 * Time: 11:38:35 AM
 * To change this template use File | Settings | File Templates.
 */
public enum DocumentTypes {
    EXPERIMENTS("experiments"),
    FILES("files"),
    PROTOCOLS("protocols"),
    ARRAYDESIGNS("array_designs");

    private final String textName;


    DocumentTypes(String textName) {
        this.textName = textName;
    }

    public String getTextName() {
        return textName;
    }
}
