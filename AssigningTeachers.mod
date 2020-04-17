
int cantidadFranjasHorarias = ...;
range FranjaHoraria = 1..cantidadFranjasHorarias; 	
{string} DiasLaborables = ...; 

{string} Profes = ...;
{string} Cursos = ...;

/*
tuple DisponibilidadCurso {
  key string curso;
  {int} franjasHorarios;
};

tuple DisponibilidadDocente {
  key string profe;
  {int} franjasNoDisponibles;
}
*/

{int} JornadaDocente[Profes][DiasLaborables] = ...;
{int} DisponibilidadCursos[Cursos][DiasLaborables] = ...;


// {DisponibilidadDocente} DisponiblidadDocente = ...; // Dias pintados en verde por cada docente
// {int} NoDisponibilidadDocente[DiasLaborables] = ...; // Franjas horarias en blancos por cada dia laboral
// {int} DisponibilidadCurso[DiasLaborables] = ...;
// {int} NoDisponibilidadCurso[DiasLaborables] = ...;

dvar int+ DocenteCubrioCursoEnHorario[Profes][Cursos][DiasLaborables][FranjaHoraria];

dexpr int cantidadCoberturas =
	sum(i in Profes, j in Cursos, k in DiasLaborables, t in FranjaHoraria) DocenteCubrioCursoEnHorario[i][j][k][t];

// dexpr int cantidadCoberturasCurso =
//	sum(i in Profes, j in Cursos) coberturasPorCurso[i][j];

maximize cantidadCoberturas;

subject to {
  // Un docente no puede tener dos cursos en un mismo horario
  forall(p in Profes, d in DiasLaborables, f in FranjaHoraria)
    sum(curso in Cursos) DocenteCubrioCursoEnHorario[p][curso][d][f] <= 1;
     
  // Lo mismo, un curso no puede tener dos profes en un mismo horario
   forall(c in Cursos, d in DiasLaborables, f in FranjaHoraria)
   	sum(profe in Profes) DocenteCubrioCursoEnHorario[profe][c][d][f] <= 1;
 
  // Dos docentes no pueden cubrir la misma clase
  forall(profe in Profes, profePrima in Profes, curso in Cursos, 
  	dia in DiasLaborables, franja in FranjaHoraria: (profe != profePrima))
	(DocenteCubrioCursoEnHorario[profe][curso][dia][franja]) 
		+ 
	(DocenteCubrioCursoEnHorario[profePrima][curso][dia][franja]) 
		<= 1;	
   
  // Un docente no puede tomar cursos en horarios que no tiene libre
  forall(profe in Profes)
    (sum(dia in DiasLaborables, franja in JornadaDocente[profe][dia], curso in Cursos) (DocenteCubrioCursoEnHorario[profe][curso][dia][franja])) 
    	== 
    (sum(dia in DiasLaborables, franja in FranjaHoraria, curso in Cursos) (DocenteCubrioCursoEnHorario[profe][curso][dia][franja]));
   
  // Un curso no se le puede asignar un horario que no puede
  forall(curso in Cursos)
    (sum(dia in DiasLaborables, franja in DisponibilidadCursos[curso][dia], profe in Profes) DocenteCubrioCursoEnHorario[profe][curso][dia][franja]) 
    	== 
    (sum(dia in DiasLaborables, franja in FranjaHoraria, profe in Profes) DocenteCubrioCursoEnHorario[profe][curso][dia][franja]);
	
  // (OPCIONAL 1) Solo puede cubrir una franja de un curso por dia
  forall(profe in Profes, curso in Cursos, dia in DiasLaborables)
    sum(franja in FranjaHoraria) DocenteCubrioCursoEnHorario[profe][curso][dia][franja] <= 1;
    
 // (OPCIONAL 2) Si agarro un curso, debe cubrirlo en ambos dias
 forall(profe in Profes, curso in Cursos)
    sum(dia in DiasLaborables, franja in FranjaHoraria) DocenteCubrioCursoEnHorario[profe][curso][dia][franja] <= 2;
 
 // (OPCIONAL 3, PICANTE) Solo pueden cubrir hasta 4 franjas (equivalente a 2 cursos debido a OPCIONAL 1 y 2)
 forall(profe in Profes)
    sum(curso in Cursos, dia in DiasLaborables, franja in FranjaHoraria) DocenteCubrioCursoEnHorario[profe][curso][dia][franja] <= 4;
  
}


execute DISPLAY {   
  writeln(" Maxima asignacion  = " , cplex.getObjValue());
  for (var p in Profes)
    for (var c in Cursos)
    	for(var d in DiasLaborables)
    		for(var f in FranjaHoraria) {
    		  	if (DocenteCubrioCursoEnHorario[p][c][d][f] == 1) {
    		  		writeln(p, " en ", c, " el ", d, " del horario ", f);
    		  		writeln();   			  
    		  	}
  			}  	   		  			
}


