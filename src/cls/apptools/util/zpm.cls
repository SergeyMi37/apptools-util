Include apptools.core

/// research and development ZPM
Class apptools.util.zpm [ Abstract ]
{

/// Storage of work history
Parameter GN = "^%apptools.ZpmLoad";

/// zpm-utility 
/// repo -r -n registry -url http://127.0.0.1:52773/registry/ -user "superuser" -pass "pass"
/// do ##class(apptools.util.zpm).LoadRegistrys("realworld")
ClassMethod LoadRegistrys(modulename = "", all = 0, skipZPM = 1) As %Status
{
	set gn=..#GN
	set sql="select Name, Version, Repo from %ZPM_PackageManager_Developer.Utils_GetModuleList('registry') "_$s(modulename="":"",1:"where Name=?")
		,rs=##class(%ResultSet).%New()
		,sc=rs.Prepare(sql)
	set:sc sc=rs.Execute($zconvert(modulename,"L"))
	if sc {
		for i=1:1 {
			quit:'rs.%Next()  
			set name=rs.Get("Name")
			set Version=rs.Get("Version")
			set Repo=rs.Get("Repo")
			set ns=$zconvert($tr(name,"-."),"U")
			if skipZPM, name["isc-apptools"||($e(name,1,3)="zpm") w !,"Skip" continue
			if $d(@gn@(name)) { ;already load
				if $lg($g(@gn@(name,"generate")),2)'=""||($lg($g(@gn@(name,"install")),1)'="") {
					write !,ns_" Removed DB ? Y\N " Read R   quit:"q"[R
					if $g(R)="y" {
						do ##class(apptools.util.zpm).DeleteDBNS(name,,,gn)
					}
					continue
				}
				write !,"Already loaded - Skip"
			} elseif 1 {
				set sta=##class(%ZPM.PackageManager).Shell("find -r -d "_name) write !
				if 'sta s err=$System.Status.GetErrorText(sta) w !,err w !,"Skip" continue
				if 'all w !,ns_" Load into a new database ? Y\N " Read R   quit:"q"[R
				if $g(R)="y"||(all=1) {
					do ##class(apptools.util.zpm).CreateAndLoad(name,,,gn)
				}
			}
		}
	}
}

/// d ##class(apptools.util.zpm).DeleteDBNS("sync-dstime")
ClassMethod DeleteDBNS(name, Version = "", Repo = "", gn = {..#GN}) As %Status
{
	s ns=$zconvert($tr(name,"-."),"U")
	s st=##class(apptools.core.GenerateDB).DeleteDBNS(ns, 1)
	i 'st w $system.Status.GetErrorText(st)
	else  k @gn@(name)
}

/// d ##class(apptools.util.zpm).CreateAndLoad("sync-dstime")
ClassMethod CreateAndLoad(name, Version = "", Repo = "", gn = {..#GN}) As %Status
{
	k err w !
	s ns=$zconvert($tr(name,"-."),"U")
	s st=##class(apptools.core.GenerateDB).Install(ns,0, ns, 1)
	i 'st s err=$System.Status.GetErrorText(st) w !,err
	s @gn@(name,"generate")=$lb(ns,$g(err),st)
	if st {
		zn ns
		;s sta=$zpm("install "_name_" -v")
		k err
		w !,"zmp ""install "_name_""""
		s sta=##class(%ZPM.PackageManager).Shell("install "_name)
		i 'sta s err=$System.Status.GetErrorText(sta) w !,err
		s @gn@(name,"install")=$lb($g(err),sta,Version,Repo)
	}
}

/// Set sc = $$$ADDSC(sc,..CreateProduction()) quit:$$$ISERR(sc)
ClassMethod CreateProduction(purge As %Boolean = 0) As %Status [ Private ]
{
    New $Namespace
    Set $Namespace = ..#NAMESPACE
    Set sc = $$$OK
    Try {
         #; create new production
        Set class = ##class(%Dictionary.ClassDefinition).%New(..#PRODUCTION)
        Set class.ProcedureBlock = 1
        Set class.Super = "Ens.Production"
        Set class.GeneratedBy = $ClassName()
        Set xdata = ##class(%Dictionary.XDataDefinition).%New()
        Set xdata.Name = "ProductionDefinition"
        Do xdata.Data.Write("<Production Name="""_..#PRODUCTION_""" LogGeneralTraceEvents=""true""></Production>")  
        Do class.XDatas.Insert(xdata)
        Set sc = $$$ADDSC(sc,class.%Save())
        Set sc = $$$ADDSC(sc,$System.OBJ.Compile(..#PRODUCTION,"fck-dv"))
        Set production = ##class(Ens.Config.Production).%OpenId(..#PRODUCTION)
        Set item = ##class(Ens.Config.Item).%New()
        Set item.ClassName = "diashenrique.messageviewer.Service.REST"
        Do production.Items.Insert(item)
        Set sc = $$$ADDSC(sc,production.%Save())
        Set item = ##class(Ens.Config.Item).%New()
        Set item.ClassName = "diashenrique.messageviewer.Operation.Consumer"
        Do production.Items.Insert(item)
        Set sc = $$$ADDSC(sc,production.%Save())    
        Set item = ##class(Ens.Config.Item).%New()
        Set item.ClassName = "diashenrique.messageviewer.Service.SendMessage"
        Do production.Items.Insert(item)
        Set sc = $$$ADDSC(sc,production.%Save())    
        Set item = ##class(Ens.Config.Item).%New()
        Set item.ClassName = "diashenrique.messageviewer.Operation.ConsumeMessageClass"
        Do production.Items.Insert(item)
        Set sc = $$$ADDSC(sc,production.%Save())    
    }
    Catch (err) {
        Set sc = $$$ADDSC(sc,err.AsStatus())
    }
    Return sc
}

ClassMethod compile(Class As %String = "", package As %String = "") As %Status
{
 q $$$OK
 s ^%qCacheObjectSys("strictchecking")=0
 k er d $system.OBJ.CompileAll("cfk-u-d",.er) zw er
 ;CompileAllNamespaces
 ;d $system.OBJ.CompileAllNamespaces()
 ;d $system.OBJ.CompilePackage(package,"cdfk-u")
 
 ;w $$defdir^%SYS.GLO($namespace) ;w $zu(12,"")

 ;zn "%SYS"
 ;d ##class(Config.CPF).PendingRestart(.r)
 ;d ##class(Config.CPF).Validate()
 ;d ##class(Config.CPF).Activate()
 ;zw ^SYS("CONFIG") ;Config.CPF
 ;^%SYS
 ;zw ^SYS("Security") - all users, privileges, roles, resources and applications
}

/// When going from Ensemble to IRIS
/// zn "app" w !,$System.Status.GetErrorText(##class(apptools.core.sys).DismountListDB("AAA"))
/// d ##class(apptools.util.zpm).RenameDB4IRIS("/opt2/isc/iris/mgr/AAA/")
/// zn "app" w !,$System.Status.GetErrorText(##class(apptools.core.sys).MountListDB("AAA"))
ClassMethod RenameDB4IRIS(dir) As %Status
{
	do ##class(apptools.core.files).GetAllDir(dir,,.L)
	set i=""
	for  { set i=$o(L(i)) quit:i=""
		set file=$lg(L(i),1)
		w !,file
		if $p(file,$$$slash,*)="CACHE.DAT" {
			s newfile=$replace(file,"CACHE","IRIS")
			If ##class(%File).Rename(file,newfile) w !,"renamed ",newfile
		}
		elseif $p(file,$$$slash,*)="cache.lck" {
			If ##class(%File).Delete(file) w !,"removed "_file
		}
	}
}

/// Recompilation to IRIS namespace
/// d ##class(apptools.util.zpm).CompNS("AAA")
ClassMethod CompNS(ns) As %Status
{
	zn ns
	d ##class(%EnsembleMgr).EnableNamespace(ns,1)
	w !,"Compilation started, please wait..."
	k err d $system.OBJ.CompileAll("cfk-u-d",.err) zw err
	q $$$OK
}

/// IRIS area processing package after copying the database from Ensemble
/// d ##class(apptools.util.zpm).RecovNS("AAA")
ClassMethod RecovNS(ns) As %Status
{
	set st=##class(apptools.core.sys).DismountListDB(ns)
	if st {
		d ##class(apptools.MSW.Test).RenameDB4IRIS("/opt/isc/iris/mgr/"_ns_"/")
		set st=##class(apptools.core.sys).MountListDB(ns)
		if st {
			d ##class(apptools.util.zpm).CompNS(ns)
		} else {
			w !,$System.Status.GetErrorText(st)
		}
	} else {
		w !,$System.Status.GetErrorText(st)
	}
}

ClassMethod CollectPackage(pPath As %String, Output pList, pRoot As %String)
{
  set rs = ##class(%File).FileSetFunc(pPath)
  WHILE rs.%Next() {
    If rs.Type="D" {
      do ..CollectPackage(rs.Name, .pList, pRoot)
    } ELSE {
      #; Set $LISTBUILD(url) = $SYSTEM.CSP.FilenameToUrls(rs.Name) 
      Set pList($INCREMENT(pList)) = $LISTBUILD(rs.Name, $EXTRACT(rs.Name, $LENGTH(pRoot) + 1, *))
    }
  }
}

ClassMethod CompactPackage(ByRef pList, classname = {$CLASSNAME()}) As %Status
{
  set file = ""
  for i=1:1:$Get(pList) {
    Set $LISTBUILD(file, name) = pList(i)
    
    set tmpFile = ##class(%File).TempFilename("gz")

    set stream = ##class(%Stream.FileBinary).%New()
    set stream.Filename = file

    Set gzip = ##class(%Stream.FileBinaryGzip).%New()
    Set gzip.Filename = tmpFile
    do gzip.CopyFromAndSave(stream)
    
    Set gzip = ##class(%Stream.FileBinary).%New()
    Set gzip.Filename = tmpFile

    Set xdata = ##class(%Dictionary.XDataDefinition).%New()
    Set xdata.Name = "Data"_i
    Set xdata.Description = name
    Do xdata.parentSetObjectId(classname)
    set chunkSize = 22800
    while 'gzip.AtEnd {
      set data = gzip.Read(chunkSize)
      set base64 = $SYSTEM.Encryption.Base64Encode(data)
      do xdata.Data.WriteLine(base64)
      set data1 = $SYSTEM.Encryption.Base64Decode(base64)
    }
    do xdata.%Save()
    set hash = $SYSTEM.Encryption.SHA1HashStream(gzip)
  
    do ##class(%File).Delete(tmpFile)
  }
  QUIT $$$OK
  
  
  Quit $$$OK
}

ClassMethod ExtractPackage(Output pFolder As %String, classname = {$CLASSNAME()}) As %String
{
  Set pFolder = ##class(%File).NormalizeDirectory($$$FileTempDir)

  For i=1:1:..#FILESCOUNT {
    Set xdata = ##class(%Dictionary.XDataDefinition).%OpenId(classname_"||Data"_i)
    Set name = xdata.Description
    Set fileName = pFolder_name

    Set tParentFolder = ##class(%File).ParentDirectoryName(fileName)    
    if '##class(%File).DirectoryExists(tParentFolder) {
      Do ##class(%File).CreateDirectoryChain(tParentFolder)
    }

    set tmpFile = ##class(%File).TempFilename("gz")

    set stream = ##class(%Stream.FileBinary).%New()
    set stream.Filename = tmpFile
    set prev = ""
    set chunkSize = 30400
    do {
      set data = prev
      if 'xdata.Data.AtEnd {
        set data = data _ xdata.Data.Read()
      }
      set data = $ZSTRIP(data, "*C")
      set prev = $EXTRACT(data, chunkSize + 1, *)
      set data = $EXTRACT(data, 1, chunkSize)
      set chunk = $SYSTEM.Encryption.Base64Decode(data)
      do stream.Write(chunk)
    } while (prev'="")||('xdata.Data.AtEnd)
    do stream.%Save()

    set gzip = ##class(%Stream.FileBinaryGzip).%New()
    set gzip.Filename = tmpFile

    set fs = ##class(%Stream.FileCharacter).%New()
    set fs.Filename = fileName
    do fs.CopyFromAndSave(gzip)

    do ##class(%File).Delete(tmpFile)
  }
  Quit $$$OK
}

/// Add XDATA to another class
///  d ##class(apptools.util.zpm).add2xdata("/backup/iris/distr/apptools-task/","Test.test")
ClassMethod add2xdata(dir = "d:\_proj\_zpm\appt-core\src\cls\", classname)
{
	;w $classname() q
	Do ..CollectPackage(dir, .tList, dir)
	zw tList
    ;Do ##class(%ZPM.Installer).CompactPackage(.tList,"App.MSW.type")
    Do ..CompactPackage(.tList,classname)
}

}

