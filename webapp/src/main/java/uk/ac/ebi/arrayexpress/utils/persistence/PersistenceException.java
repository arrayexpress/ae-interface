package uk.ac.ebi.arrayexpress.utils.persistence;

/**
 * Created by IntelliJ IDEA.
 * User: nataliyasklyar
 * Date: Jun 17, 2010
 * Time: 11:36:40 AM
 * To change this template use File | Settings | File Templates.
 */
public class PersistenceException extends RuntimeException{

    public PersistenceException() {
        super();    //To change body of overridden methods use File | Settings | File Templates.
    }

    public PersistenceException(String s) {
        super(s);    //To change body of overridden methods use File | Settings | File Templates.
    }

    public PersistenceException(String s, Throwable throwable) {
        super(s, throwable);    //To change body of overridden methods use File | Settings | File Templates.
    }

    public PersistenceException(Throwable throwable) {
        super(throwable);    //To change body of overridden methods use File | Settings | File Templates.
    }
}
