// Parameters
int i = ...;
range I = 0..i;
int j = ...;
range J = 0..j;
int nbtruck = ...;
range truckth = 1..nbtruck;

float c[I][J] = ...;
float t[I][J] = ...;
float d[J] = ...;
float a[I] = ...;
float b[I] = ...;
float st[J] = ...;
int Q = ...;
float cost = ...;

// Decision variables
dvar boolean x[truckth][I][J];
dvar float+ s[truckth][I];
dvar float+ se[truckth][J];

// Big M
dexpr float M = max(i in I, j in J) (b[i] + t[i][j] - a[i]);

// Objective function
minimize sum(i in I, j in J, k in truckth: i != j) c[i][j]*x[k][i][j]*cost;

// Constraints
subject to {
    Constraint_01:
    forall (k in truckth, j in J)
        sum (i in I: i != j) x[k][i][j] - sum (i in I: i != j) x[k][j][i] == 0; 

    Constraint_02:
    forall (j in J: j != 0)
        sum (i in I, k in truckth: j != i) x[k][i][j] == 1;

    Constraint_03:
    forall (k in truckth)
        sum (j in J: j != 0) x[k][0][j] == 1;
    
    Constraint_04:
    forall (k in truckth)
        sum (j in J, i in I: i != j && j != 0) d[j]*x[k][i][j] <= Q;

    Constraint_05:
    forall (k in truckth, i in I, j in J: i != j)
        if (j != 0) {
            s[k][i] + t[i][j] + st[i] - M*(1 - x[k][i][j]) <= s[k][j];
        } else {
            s[k][i] + st[i] + t[i][0] <= b[0];
        }
    
    Constraint_06:
    forall (i in I, k in truckth)
        a[i] <= s[k][i] <= b[i];
    
    SubVariable:
    forall (k in truckth, i in I, j in J: i != j)
        if (j != 0) {
            x[k][i][j] == 1 => se[k][j] == s[k][i] + st[i] + t[i][j];
        }
        else {
            x[k][i][0] == 1 => se[k][0] == s[k][i] + st[i] + t[i][0]; 
        } 
}

execute WRITE_RESULT {
    var ofile = new IloOplOutputFile("Result.txt");
    ofile.writeln("The objective function value: ", cplex.getObjValue());
    for (var k in truckth) {
        for (var i in I) {
            for (var j in J) {
                if (x[k][i][j] == 1) {
                    if (j != 0) {
                        var tripStartTime = s[k][j] - t[i][j];
                        var serviceStartTime = s[k][j];
                        var serviceEndTime = s[k][j] + st[j];
                    } else {
                        tripStartTime = se[k][0] - t[i][0];
                        serviceStartTime = se[k][0];
                        serviceEndTime = serviceStartTime;
                    }
                    ofile.writeln("Truck ", k, " Delivers from ", i, " To ", j,
                        " starts trip at: ", tripStartTime,
                        ", starting service at: ", serviceStartTime,
                        " and ending at: ", serviceEndTime);
                }
            }
        }
    }
}
