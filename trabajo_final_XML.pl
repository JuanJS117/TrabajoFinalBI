##---------------------------------------
##PROGRAMA PARA EL MANEJO DE BIBLIOGRAFÍA
##---------------------------------------

##Realizado por: Juan Jiménez Sánchez.
##Programación para Bioinformática. 4º Biotecnología.

##El siguiente programa permite manipular referencias bibliográficas. En concreto, es capaz de realizar 3 tareas:
##1º: Guardar información sobre artículos científicos (obtenidos en PubMed) en una base de datos creada para tal efecto.
##2º: Buscar y mostrar información relativa a dichos artículos en la misma base de datos.
##3º: Incluir referencias bibliográficas en archivos de texto.

##La interfaz guiará al usuario a la hora de realizar estas tareas. Como se indica más adelante, según la tarea,
##será necesario especificar un nombre de archivo, una opción numérica, o un campo de búsqueda, dependiendo del caso.

##En la 3º tarea, dicha inclusión solo se producirá si el texto suministrado posee una expresión acotada por los siguientes
##caracteres especiales: #!#EXPRESIÓN#!#. Dicha expresión debe consistir en el código primario interno de la base de datos
##asociado a un artículo determinado. Si la expresión consiste en otro término, no se podrá acceder a ningún artículo,
##y no se incluirá la referencia bibliográfica en el texto.

use strict;
#use warnings;
use DBI;

##--------------------------------------------------------------
##A continuación se declaran las variables que se van a utilizar
##--------------------------------------------------------------

my$archivo_xml;
my@datos;
my@entradas;
my@info_entrada;
my$seguir;
my$respuesta;
my$valido;
my$seguir2;
my$respuesta2;
my$patron_busqueda;
my@resultados;
my$campo;
my$exito;
my$archivo_txt;
my$contador;
my@nuevos_datos;
my$clave_primaria;
my$autores;
my$titulo_revista;
my$titulo_articulo;
my$PMID;
my$fecha;
my$ref_bibliografica;
my$ref_abreviada;
my@refs;

##------------------------------------------------------
##El siguiente código muestra el desarrollo del programa
##------------------------------------------------------

print "\n-----------------------------------------";
print "\n|PROGRAMA PARA EL MANEJO DE BIBLIOGRAFÍA|";
print "\n-----------------------------------------\n\n";
print "\tBuenos días. ¿Qué desea hacer?\n\n";
$seguir=1;
while ($seguir==1){
  $valido=0;
  print "\tUsted tiene 4 opciones:\n\t\tGuardar campos de artículos nuevos en la base de datos (OPCIÓN 1);\n\t\tBuscar información de un artículo en la base de datos (OPCIÓN 2);\n\t\tSustituir expresión especial en texto por referencia bibliográfica (OPCIÓN 3);\n\t\tNo hacer nada (OPCIÓN 4).\n";
  print "\nTECLEE EL NÚMERO DE LA OPCIÓN QUE DESEE REALIZAR --> ";
  my$opcion=<STDIN>;
  chomp($opcion);
  #print "/$opcion/";
  if ($opcion!=1 and $opcion!=2 and $opcion!=3 and $opcion!=4){
    print "\nPor favor, escoja una opción válida (1, 2, 3 o 4) la próxima vez";
  }elsif ($opcion==1){
    print "\nHa escogido la opción: guardar nuevos artículos en la base de datos.\n";
    print "Para guardar información sobre artículos nuevos, debe proporcionar\nun archivo.xml obtenido a partir de una búsqueda en PubMed.\n";
    print "\nIndique a continuación el nombre del archivo cuyo contenido desea guardar en la base de datos --> ";
    $archivo_xml=<STDIN>;
    chomp($archivo_xml);
    @datos=&Open_file($archivo_xml);
    #foreach my$element(@datos){
    #  print "$element\n--------------------------------------------------\n";
    #} #Para el archivo.xml, cada $element se corresponde con una línea del archivo.
    @entradas=&Create_entries(@datos);
    foreach my$elemento(@entradas){
      $elemento=&Trim_unwanted_characters($elemento);
    ##  print "$elemento\n-------------------------------\n";
      @info_entrada=&Parse_NCBI_xml_file($elemento);
      $exito=&Insert_entry_into_DB(@info_entrada);
    }
    if ($exito==1){
      print "\nLa información de su archivo ha sido correctamente guardada en la base de datos.";
    }else{
      print "\nNo se ha podido guardar toda la información.";
    }
    #@info_entrada=&Parse_NCBI_xml_file($entradas[10]);
    while ($valido==0){
      print "\n¿Desea realizar alguna operación adicional? (S/N) --> ";
      $respuesta=<STDIN>;
      chomp ($respuesta);
      $respuesta=uc($respuesta);
      if ($respuesta=~"S"){
        $valido=1;
      }elsif ($respuesta=~"N"){
        $valido=1;
        $seguir=0;
        print "La ejecución del programa ha terminado. ¡Hasta pronto!\n";
      }else{
        print "\nSeleccione una respuesta válida, por favor\nS (Sí) para continuar;\nN (No) para terminar la ejecución.\n";
      }
    }
  }elsif ($opcion==2){
    $seguir2=1;
    print "\nHa escogido la opción: buscar información sobre un artículo en la base de datos.\n";
    print "Usted puede buscar información sobre artículos haciendo referencia a campos como los autores, el título del artículo, el PMID, etc";
    while ($seguir2==1){
      print "\n¿Sobre qué campo desea buscar información en la base de datos?\n";
      print "\tCódigo primario interno (Propio de la base de datos)(OPCIÓN 1)\n\tTítulo del artículo (OPCIÓN 2)\n\tNombre de la revista (OPCIÓN 3)\n\tAutores (OPCIÓN 4)\n\tAbstract (OPCIÓN 5)\n\tPMID (OPCIÓN 6)\n";
      print "\nTeclee el número de la opción que desea realizar --> ";
      $respuesta2=<STDIN>;
      chomp ($respuesta2);
      if ($respuesta2!=1 and $respuesta2!=2 and $respuesta2!=3 and $respuesta2!=4 and $respuesta2!=5 and $respuesta2!=6){
        print "\nPor favor, escoja una opción válida (1, 2, 3, 4, 5 o 6) la próxima vez";
      }elsif ($respuesta2==1){
        $seguir2=0;
        $campo="idArticulo_pubmed";
        print "\nPor favor, escriba el código interno asociado al artículo que desea encontrar --> ";
        $patron_busqueda=<STDIN>;
        chomp ($patron_busqueda);
        @resultados=&Search_pattern_in_ArticuloPubmed_DB($patron_busqueda,$campo);
      }elsif ($respuesta2==2){
        $seguir2=0;
        $campo="Titulo";
        print "\nPor favor, escriba el código interno asociado al artículo que desea encontrar --> ";
        $patron_busqueda=<STDIN>;
        chomp ($patron_busqueda);
        @resultados=&Search_pattern_in_ArticuloPubmed_DB($patron_busqueda,$campo);
      }elsif ($respuesta2==3){
        $seguir2=0;
        $campo="Revista";
        print "\nPor favor, escriba el código interno asociado al artículo que desea encontrar --> ";
        $patron_busqueda=<STDIN>;
        chomp ($patron_busqueda);
        @resultados=&Search_pattern_in_ArticuloPubmed_DB($patron_busqueda,$campo);
      }elsif ($respuesta2==4){
        $seguir2=0;
        $campo="Autores";
        print "\nPor favor, escriba el código interno asociado al artículo que desea encontrar --> ";
        $patron_busqueda=<STDIN>;
        chomp ($patron_busqueda);
        @resultados=&Search_pattern_in_ArticuloPubmed_DB($patron_busqueda,$campo);
      }elsif ($respuesta2==5){
        $seguir2=0;
        $campo="Abstract";
        print "\nPor favor, escriba el código interno asociado al artículo que desea encontrar --> ";
        $patron_busqueda=<STDIN>;
        chomp ($patron_busqueda);
        @resultados=&Search_pattern_in_ArticuloPubmed_DB($patron_busqueda,$campo);
      }elsif ($respuesta2==6){
        $seguir2=0;
        $campo="PMID";
        print "\nPor favor, escriba el PMID asociado al artículo que desea encontrar --> ";
        $patron_busqueda=<STDIN>;
        chomp ($patron_busqueda);
        @resultados=&Search_pattern_in_ArticuloPubmed_DB($patron_busqueda,$campo);
      }
    }
    while ($valido==0){
      print "\n\n\n¿Desea realizar alguna operación adicional? (S/N) --> ";
      $respuesta=<STDIN>;
      chomp ($respuesta);
      $respuesta=uc($respuesta);
      if ($respuesta=~"S"){
        $valido=1;
      }elsif ($respuesta=~"N"){
        $valido=1;
        $seguir=0;
        print "La ejecución del programa ha terminado. ¡Hasta pronto!\n";
      }else{
        print "\nSeleccione una respuesta válida, por favor\nS (Sí) para continuar;\nN (No) para terminar la ejecución.\n";
      }
    }
  }elsif ($opcion==3){
    print "\nHa escogido la opción: sustituir expresión especial en texto por referencia bibliográfica.\n";
    print "\nCon esta opción, usted puede sustituir expresiones acotadas por caracteres especiales\n";
    print "por referencias bibliográficas. La expresión acotada debe ir en el siguiente formato: \#!\#EXPRESIÓN\#!\#.\n";
    print "La expresión solo debe incluir el código numérico primario asociado al artículo referenciado. Dicho código\n";
    print "es un número que va de 1 a n, siendo n el número de artículos totales en la base de datos.\n";
    print "\nPara realizar tal sustitución, debe proporcionar un texto incluido en un archivo.txt.\n";
    print "El programa se encargará de buscar la expresión especial y sustituirla por la referencia bibliográfica.";
    print "\nEn pantalla se mostrarán los artículos referenciados en el texto.\n";
    print "\nIndique a continuación el nombre del archivo en el cual desea procesar las referencias bibliográficas --> ";
    $archivo_txt=<STDIN>;
    chomp($archivo_txt);
    @datos=&Open_file($archivo_txt);
    $contador=0;
    $campo="idArticulo_pubmed";
    foreach my$elemento(@datos){
      if ($elemento=~/\#\!\#([0-9]+)\#\!\#/g){
        $clave_primaria=$1;
        $contador=$contador+1;
        #print "Se ha encontrado una referencia bibliográfica!!";
        @resultados=&Search_pattern_in_ArticuloPubmed_DB($clave_primaria,$campo);
        $autores=$resultados[1];
        $autores=~s/\n/, /g;
        $autores=~s/(\w)\,(\w)/$1 $2/g;
        my$autores_length=length($autores);
        $autores=substr($autores,0,$autores_length-2);
        #print "$autores";
        $titulo_revista=$resultados[0];
        $titulo_articulo=$resultados[2];
        $PMID=$resultados[3];
        $fecha=$resultados[4];
        my$fecha_length=length($fecha);
        $fecha=substr($fecha,0,$fecha_length-1);
        $ref_bibliografica="\n[$contador] $autores.$fecha. '$titulo_articulo' $titulo_revista. PMID: $PMID.\n";
        $autores=~s/([\s\S]*?)\,(.*)/$1 et al,/g;
        $ref_abreviada="([Ref. nº $contador] '$fecha.')";
        $elemento=~s/\#\!\#[0-9]+\#\!\#/"[Ref. $contador]($autores$fecha.)"/;
        push (@refs,$ref_bibliografica);
      }
      push(@nuevos_datos,$elemento);
    }
    my$nuevo_contenido=join("",@nuevos_datos);
    &Overwrite_file($archivo_txt,$nuevo_contenido);
    foreach my$ref(@refs){
      &Append_to_file($archivo_txt,$ref);
    }
    while ($valido==0){
      print "\n\n\n¿Desea realizar alguna operación adicional? (S/N) --> ";
      $respuesta=<STDIN>;
      chomp ($respuesta);
      $respuesta=uc($respuesta);
      if ($respuesta=~"S"){
        $valido=1;
      }elsif ($respuesta=~"N"){
        $valido=1;
        $seguir=0;
        print "La ejecución del programa ha terminado. ¡Hasta pronto!\n";
      }else{
        print "\nSeleccione una respuesta válida, por favor\nS (Sí) para continuar;\nN (No) para terminar la ejecución.\n";
      }
    }
  }elsif ($opcion==4){
    print "\nHa escogido la opción 4.\n";
    $seguir=0;
    print "La ejecución del programa ha terminado. ¡Hasta pronto!\n";
  }
}


##-----------------------------------------
##A partir de aquí comienzan las subrutinas
##-----------------------------------------

sub Open_file{#Subrutina para abrir un archivo.
	my$file=$_[0];#El archivo es pasado como argumento del script a ejecutar en la línea de comandos.
	my@data=&Test_open_file($file);
	return @data;
}

sub Test_open_file{#Subrutina para comprobar que la apertura de un archivo ha sido realizada correctamente.
	my$file=$_[0];
	unless(open(INPUT,$file)){#Realmente la apertura es realizada en esta subrutina. En la subrutina "Open_file" simplemente se llama a la subrutina actual, y se extrae el contenido del archivo.
		print "Cannot open file $file. Try again.\n";
		exit;
	}
	my@data=<INPUT>;
	close INPUT;
	return @data;
}

sub Trim_unwanted_characters{#Algunos caracteres dan lugar a errores durante la ejecución de la query. Con esta subrutina podemos eliminarlos a partir del archivo original
  my$data=$_[0];
  $data=~s/\'//g;
  return $data;
}

sub Trim_newlines{
  my$data=$_[0];
  $data=~s/\s{2,}//g;
  $data=~s/\;/\n/g;
  return $data;
}

sub Create_entries{#Subrutina que agrupa las líneas del archivo.xml según el artículo al que pertenecen.
  my@data=@_;
  my$entry="";
  my@entries;
  foreach my$element(@data){
    if ($element!~"<PubmedArticle>"){#Esta expresión regular funciona en todos los casos comprobados
      $entry=$entry.$element;
      if ($element=~"</PubmedArticle>"){
        push(@entries,$entry);
      }
    }elsif ($element=~"<PubmedArticle>"){
      $entry="";
      $entry=$entry.$element;
    }
  }
  return @entries;
}

sub Parse_NCBI_xml_file{
  my$entry=$_[0];#A pesar de recibir cada entrada como un array, la reconoce correctamente
  #print "@entry\n--------------------\n";
  #/^[0-9]+\.\s(.*)\n([^\s]+)/ --> Esta expresión regular detecta los inicios de entradas cuya revista ocupa más de una línea
  #my$entry=join("",@entry);
  my$abstract;
  my$PMID;
  my$journal;
  my$title;
  my$authors;
  my$author_info="";
  my$pub_date;
  if ($entry=~/<PMID\s\S*>([0-9]+)<\/PMID>\s*<DateCreated>/){#Funciona perfectamente con todos los PMIDs
    $PMID=$1;
    #print "$PMID\n";
  }
  if ($entry=~/<PubDate>([\s\S]*?)<\/PubDate>/){#Funciona perfectamente con todos los PMIDs
    $pub_date=$1;
    $pub_date=~s/\<.*?\>/ /g;
    $pub_date=~s/\s{2,}/ /g;
    #print "$pub_date\n";
  }
  if ($entry=~/<Title>([\s\S]*?)<\/Title>/){#Funciona perfectamente con todos los nombres de revista
    $journal=$1;
    #print "$journal\n";
  }
  if ($entry=~/<ArticleTitle>([\s\S]*?)<\/ArticleTitle>/){#Funciona perfectamente con todos los títulos de artículo
    $title=$1;
    #print "$title\n";
  }
  if ($entry=~/<Abstract>([\s\S]*?)<\/Abstract>/){#Funciona con todos los abstract
    $abstract=$1;
    if ($entry=~/<AbstractText[\s\S]*?>/){
      $abstract=~s/<AbstractText[\s\S]*?\=([\S]*?)>/$1 /g;
      $abstract=~s/<\/AbstractText>/ /g;
      $abstract=~s/<AbstractText>/ /g;
      $abstract=~s/\"UNASSIGNED\"/ /g;
      $abstract=~s/<\/CopyrightInformation>/ /g;
      $abstract=~s/<CopyrightInformation>/ /g;
    }
    #print "$abstract\n";
  }
  if ($entry=~/<AuthorList.*?>([\s\S]*?)<\/AuthorList>/){
    $authors=$1;
    $author_info=$1;
    $authors=~s/<LastName>([\s\S]*?)<\/LastName>[\s]*?<ForeName>([\s\S]*?)<\/ForeName>/$1,$2;/g;
    $author_info=~s/<AffiliationInfo>[\s]*?<Affiliation>([\s\S]*?)<\/Affiliation>[\s]*?<\/AffiliationInfo>/$1;/g;
    $authors=~s/\<.*\>//g;
    $author_info=~s/\<.*\>//g;
    $authors=&Trim_newlines($authors);
    $author_info=&Trim_newlines($author_info);
    #print "$authors\n";
    #print "$author_info\n";
  }
  #print "\n--------------------------------------------\n";
  my@entry_info=($title,$authors,$journal,$author_info,$abstract,$PMID,$pub_date);
  return @entry_info;
}

sub Insert_entry_into_DB{
  my@entry_info=@_;
  my$success=0;

  my$db = "bioinformatica_PF";
  my$user = "bi_pf";
  my$pass = "juanjimenezsanchez";
  my$host = "localhost";

  ## SQL query
  my$query = "INSERT INTO Articulo_pubmed (Titulo, Autores, Revista, Info_Autores, Abstract, PMID, Fecha_publicacion) VALUES ('$entry_info[0]', '$entry_info[1]', '$entry_info[2]', '$entry_info[3]', '$entry_info[4]', '$entry_info[5]', '$entry_info[6]')";
  my$dbh = DBI->connect("DBI:mysql:$db:$host", $user, $pass);
  my$sqlQuery  = $dbh->prepare($query) or die "Error preparando la query: $dbh->errstr\n";
  my$rv = $sqlQuery->execute or die "Error ejecutando la query: $sqlQuery->errstr";
  $success=1;
  #print "Resultados de la query:\n";
  #$count=0;
  #while (@row= $sqlQuery->fetchrow_array()) {
  #	print "disease name: " . "$row[0]\n";
  #	print "  pathogen name: " . "$row[1]\n";
  #	print "    host name: " . "$row[2]\n";
  #	$count=$count+1;
  #}
  #print "\nNº total de registros encontrados: $count\n\n";
  my$rc = $sqlQuery->finish;
  return $success;
}

sub Search_pattern_in_ArticuloPubmed_DB{
  my$pattern=$_[0];
  my$field=$_[1];
  $pattern="$pattern";
  my@results;
  my@pattern;
  my$patterns="$field";

  my$db = "bioinformatica_PF";
  my$user = "bi_pf";
  my$pass = "juanjimenezsanchez";
  my$host = "localhost";

  my$query;
  my$dbh;
  my$sqlQuery;
  my$rv;
  my@row;
  my$rc;
  my$count=0;
  if ($pattern!~/\s/){
    if ($pattern=~/[0-9]/){
      $query = "SELECT * FROM Articulo_pubmed WHERE $field LIKE '$pattern'";
    }else{
      $query = "SELECT * FROM Articulo_pubmed WHERE $field LIKE '%$pattern%'";
    }
    $dbh = DBI->connect("DBI:mysql:$db:$host", $user, $pass);
    $sqlQuery  = $dbh->prepare($query)
    or die "Error preparando la query: $dbh->errstr\n";
    $rv = $sqlQuery->execute
    or die "Error ejecutando la query: $sqlQuery->errstr";
    while (@row= $sqlQuery->fetchrow_array()) {
      $count=$count+1;
      print "\n/////////////////////////////\n";
      print "\nArtículo nº: $count\n";
      print "\n/////////////////////////////\n";
      print "\n\tNombre de la revista:\n$row[1]\n";
      push (@results,$row[1]);
      print "------------------------------\n";
      print "\tAutores:\n$row[2]\n";
      push (@results,$row[2]);
      print "------------------------------\n";
      print "\tTítulo del artículo:\n$row[3]\n";
      push (@results,$row[3]);
      print "------------------------------\n";
      print "\nAbstract:\n$row[5]\n";
      print "------------------------------\n";
      print "\nPMID: $row[6]\n";
      push (@results,$row[6]);
      print "------------------------------\n";
      print "\nFecha de publicación: $row[7]\n";
      push (@results,$row[7]);
      print "------------------------------\n";
    }
    $rc = $sqlQuery->finish;
  }elsif ($pattern=~/\s/){
    @pattern=split(" ",$pattern);
    foreach my$element(@pattern){
      $patterns="$patterns"." LIKE '%$element%' AND $field";
    }
    my$longitud_campo=length($field);
    my$longitud_query=length($patterns);
    $patterns=substr($patterns,0,$longitud_query-$longitud_campo-5);
    #print "$patterns";
    $query = "SELECT * FROM Articulo_pubmed WHERE $patterns";
    $dbh = DBI->connect("DBI:mysql:$db:$host", $user, $pass);
    $sqlQuery  = $dbh->prepare($query)
    or die "Error preparando la query: $dbh->errstr\n";
    $rv = $sqlQuery->execute
    or die "Error ejecutando la query: $sqlQuery->errstr";
    while (@row= $sqlQuery->fetchrow_array()) {
      $count=$count+1;
      print "\n/////////////////////////////\n";
      print "\nArtículo nº: $count\n";
      print "\n/////////////////////////////\n";
      print "\n\tNombre de la revista:\n$row[1]\n";
      push (@results,$row[1]);
      print "------------------------------\n";
      print "\tAutores:\n$row[2]\n";
      push (@results,$row[2]);
      print "------------------------------\n";
      print "\tTítulo del artículo:\n$row[3]\n";
      push (@results,$row[3]);
      print "------------------------------\n";
      print "\nAbstract:\n$row[5]\n";
      print "------------------------------\n";
      print "\nPMID: $row[6]\n";
      push (@results,$row[6]);
      print "------------------------------\n";
      print "\nFecha de publicación: $row[7]\n";
      push (@results,$row[7]);
      print "------------------------------\n";
    }
    $rc = $sqlQuery->finish;
  }
  #foreach my$element(@results){
  #  print "$element\n-------------------------\n";
  #}
  print "\n/////////////////////////////\n";
  print "\nNº de artículos encontrados: $count\n";
  print "\n/////////////////////////////\n";
  return @results;
}

sub Overwrite_file{
  my$file=$_[0];
  my$what_to_write=$_[1];
  open(my$fh, '>', $file) or die "No se pudo abrir el archivo '$file' para su escritura $!";
  print $fh "$what_to_write";
  close $fh;
}

sub Append_to_file{
  my$file=$_[0];
  my$what_to_write=$_[1];
  open(my$fh, '>>', $file) or die "No se pudo abrir el archivo '$file' para su escritura $!";
  print $fh "$what_to_write";
  close $fh;
}
