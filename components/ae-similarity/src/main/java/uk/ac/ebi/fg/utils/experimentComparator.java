package uk.ac.ebi.fg.utils;

import uk.ac.ebi.fg.utils.objects.ExperimentId;

import java.util.Comparator;

public class experimentComparator implements Comparator {
    public int compare(Object experiment1, Object experiment2) {
        ExperimentId expId1 = (ExperimentId) experiment1;
        ExperimentId expId2 = (ExperimentId) experiment2;

        if ( expId1.getCalculatedDistance() != expId2.getCalculatedDistance() )
            return new Float(expId2.getCalculatedDistance()).compareTo(expId1.getCalculatedDistance());

        String exp1 = expId1.getId().substring(0,7);
        String exp2 = expId2.getId().substring(0,7);
        Integer putExp1Up = 0;
        Integer putExp2Up = 0;

        String[] up = {"E-MEXP-", "E-MTAB-", "E-TAMB-"};
        for ( int i=0; i<up.length; i++) {
            if ( exp1.equals(up[i]) )
                putExp1Up = 1;
            if ( exp2.equals(up[i]) )
                putExp2Up = 1;
        }

        if ( exp1.equals("E-GEOD-") )
            putExp1Up = -1;
        if ( exp2.equals("E-GEOD-") )
            putExp2Up = -1;

        if ( putExp1Up.equals(putExp2Up) )
            return exp1.compareTo(exp2);
        return putExp2Up.compareTo(putExp1Up);
    }
}
