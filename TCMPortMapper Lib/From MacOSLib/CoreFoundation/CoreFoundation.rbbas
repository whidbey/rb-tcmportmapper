#tag Module
Module CoreFoundation
	#tag Method, Flags = &h1
		Protected Function Version() As Double
		  // Returns the version of the CoreFoundation framework
		  
		  #if targetMacOS
		    const kCFCoreFoundationVersionNumber = "kCFCoreFoundationVersionNumber"
		    
		    dim p as Ptr = CFBundle.CarbonFramework.DataPointerNotRetained(kCFCoreFoundationVersionNumber)
		    if p <> nil then
		      return p.Double(0)
		    end if
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function XMLValue(extends propertyList as CFPropertyList) As String
		  #if TargetMacOS
		    soft declare function CFPropertyListCreateXMLData lib CarbonLib (allocator as Ptr, propertyList as Ptr) as Ptr
		    
		    dim xmlData as new CFData(CFPropertyListCreateXMLData(nil, propertyList.Reference), true)
		    return DefineEncoding(xmlData.Data, Encodings.UTF8)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFRangeMake(loc as Int32, len as Int32) As CFRange
		  dim r as CFRange
		  r.location = loc
		  r.length = len
		  return r
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Retain(extends s as CFStringRef)
		  // This function is needed for CFStringRef values returned by a Mac OS CF...Get... function.
		  //
		  // That's because the CFStringRef destructor will call CFRelease on the reference,
		  // which must be balanced with a CFRetain call so that the object does not get freed.
		  // This is because of the ownership rules which say that a CF-Get function does not
		  // transfer ownership.
		  
		  #if targetMacOS
		    declare function CFRetain lib CarbonLib (cf as CFStringRef) as Integer
		    
		    call CFRetain(s)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub _testAssert(b as Boolean, msg as String = "")
		  #if DebugBuild
		    if not b then
		      break
		      #if TargetHasGUI
		        MsgBox "Test failed: "+EndOfLine+EndOfLine+msg
		      #else
		        Print "Test failed: "+msg
		      #endif
		    end
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFString(str as String) As CFString
		  return str
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFBoolean(b as Boolean) As CFBoolean
		  if b then
		    return CFBoolean.GetTrue
		  end if
		  return CFBoolean.GetFalse
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFDate(d as Date) As CFDate
		  return new CFDate(d)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFNumber(dbl as Double) As CFNumber
		  return new CFNumber(dbl)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFURL(url as String) As CFURL
		  return new CFURL(url)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFNumber(int_32 as Integer) As CFNumber
		  return new CFNumber(int_32)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFNumber(int_64 as Int64) As CFNumber
		  return new CFNumber(int_64)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clone(Extends propertyList as CFPropertyList, mutability as Integer) As CFPropertyList
		  // mutability: kCFPropertyListImmutable, kCFPropertyListMutableContainers, kCFPropertyListMutableContainersAndLeaves
		  
		  dim pList as CFType
		  
		  #if TargetMacOS
		    Declare Function CFPropertyListCreateDeepCopy Lib CarbonLib (allocator as Integer, propertyList as Ptr, mutabilityOption as Integer) as Ptr
		    
		    dim ref as Ptr
		    ref = CFPropertyListCreateDeepCopy(0, propertyList.Reference, mutability)
		    If ref <> nil then
		      pList = CFType.NewObject(ref, true, mutability)
		    End if
		  #endif
		  
		  return CFPropertyList(pList)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsValid(extends propertyList as CFPropertyList, listFormat as Integer) As Boolean
		  // listFormat: kCFPropertyListOpenStepFormat, kCFPropertyListXMLFormat_v1_0, kCFPropertyListBinaryFormat_v1_0
		  
		  #if TargetMacOS
		    Declare Function CFPropertyListIsValid Lib CarbonLib (cf as Ptr, fmt as Integer) as Boolean
		    
		    return CFPropertyListIsValid(propertyList.Reference, listFormat)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function AvailableEncodings() As TextEncoding()
		  #if TargetMacOS
		    dim m as MemoryBlock
		    dim i as Integer
		    dim encodingList(-1) as TextEncoding
		    
		    Const kCFStringEncodingInvalidId = &hffffffff
		    
		    Declare Function CFStringGetListOfAvailableEncodings Lib CarbonLib () as Ptr
		    
		    m = CFStringGetListOfAvailableEncodings
		    
		    If m <> Nil then
		      i = 0
		      While m.Long(i) <> kCFStringEncodingInvalidId
		        encodingList.Append Encodings.GetFromCode(m.Long(i))
		        i = i + 4
		      Wend
		    Else
		      //
		    End if
		    Return encodingList
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NewCFPropertyList(theXML as String, mutability as Integer, ByRef errorMessageOut as String) As CFPropertyList
		  // mutability: kCFPropertyListImmutable, kCFPropertyListMutableContainers, kCFPropertyListMutableContainersAndLeaves
		  // Note: Returns nil if the xml data is not a valid property list
		  
		  dim pList as CFType
		  
		  #if TargetMacOS
		    declare function CFPropertyListCreateFromXMLData Lib CarbonLib (allocator as Ptr, xmlData as Ptr, mutabilityOptions as Integer, ByRef errMsg as CFStringRef) as Ptr
		    
		    dim theData as CFData
		    dim theRef as Ptr
		    
		    theData = new CFData(theXML)
		    dim strRef as CFStringRef
		    theRef = CFPropertyListCreateFromXMLData (nil, theData.Reference, mutability, strRef)
		    if theRef <> nil then
		      pList = CFType.NewObject(theRef, true, mutability)
		      errorMessageOut = ""
		    else
		      errorMessageOut = strRef
		    end if
		  #else
		    errorMessageOut = "not supported on this platform"
		  #endif
		  
		  return CFPropertyList(pList)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFConstant(name as String) As CFStringRef
		  // To be used to lookup kCF... constants only!
		  
		  return CFBundle.CarbonFramework.StringPointerRetained(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFSocketNativeHandle(handle as Integer) As CFSocketNativeHandle
		  dim h as CFSocketNativeHandle
		  h.handle = handle
		  return h
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub _TestSelf()
		  // This is an incomplete set of tests to make sure nothing got screwed up too much
		  
		  #if DebugBuild
		    
		    dim s as String
		    s = CFBundle.CarbonFramework.Identifier
		    
		    dim cft as CFType
		    
		    if true then
		      dim vals() as CFString
		      vals.Append new CFString("a")
		      vals.Append "b"
		      dim arr as new CFArray(vals)
		      dim p as Ptr = arr.Reference
		      arr = CFArray(CFType.NewObject(p, false, kCFPropertyListImmutable)) // here the ref needs to be retained
		      p = arr.Reference
		      arr = new CFArray(p, false) // here the ref needs to be retained
		      _testAssert arr.Value(1).Equals(new CFString("b"))
		    end // at this point the CFString objects should all get deallocated
		    
		    // Test CFNumber operations
		    if true then
		      dim cf1, cf2 as CFNumber
		      cf1 = new CFNumber(1)
		      _testAssert cf2=nil
		      cf2 = new CFNumber(nil,false)
		      _testAssert cf2<>nil
		      _testAssert cf2.IsNULL
		      cf2 = new CFNumber(0)
		      _testAssert not cf2.IsNULL
		      _testAssert cf1.IntegerValue > cf2.IntegerValue
		      _testAssert cf1.DoubleValue = 1
		      _testAssert cf1.Equals(new CFNumber(1.0))
		    end
		    
		    // Test the CFPreferences functionality
		    if true then
		      dim cf1 as CFNumber
		      dim prefs as CFPreferences
		      dim prefKeys() as String = prefs.Keys
		      for each key as String in prefKeys
		        dim desc as String = prefs.Value(key).Description
		      next
		      cf1 = CFNumber(prefs.Value("RunCount"))
		      dim runCount as Integer
		      if cf1 <> nil then
		        runCount = cf1.IntegerValue
		      end if
		      cf1 = new CFNumber (runCount + 1)
		      prefs.Value("RunCount") = cf1
		      call prefs.Sync // this writes back the changes to the prefs we made here
		      cft = prefs.Value("RunCount")
		      _testAssert cf1.Equals(prefs.Value("RunCount"))
		    end
		    
		    // Test CFURL
		    if true then
		      dim url as new CFURL(SpecialFolder.System)
		      _testAssert url.Scheme = "file"
		      _testAssert url.NetLocation = "localhost"
		      _testAssert url.StringValue = "file://localhost"+url.Path+"/"
		    end
		    
		    // Test CFTimeZone
		    if true then
		      dim zonenames() as String = CFTimeZone.NameList()
		      dim tzone as new CFTimeZone(zonenames(1))
		      _testAssert tzone.Name = zonenames(1)
		    end
		    
		    // Test CFStreams
		    if true then
		      dim reader as CFReadStream
		      dim writer as CFWriteStream
		      reader = new CFReadStream("12345")
		      _testAssert reader.Status = 0
		      _testAssert reader.Open()
		      _testAssert reader.Read(3,s)
		      _testAssert s = "123"
		      _testAssert not reader.IsAtEnd
		      _testAssert reader.Read(3,s)
		      _testAssert s = "45"
		      _testAssert reader.IsAtEnd
		      _testAssert reader.Read(3,s)
		      _testAssert reader.IsOpen
		      reader.Close()
		      _testAssert not reader.IsOpen
		      _testAssert not reader.Open()
		      _testAssert not reader.IsOpen
		      
		      ' not usable due to bug(?) in OS 10.5:
		      'if CFStream.NewBoundPair (reader, writer) then
		      '_testAssert reader.Open
		      '_testAssert writer.Open
		      '_testAssert writer.IsReady
		      '_testAssert not reader.HasDataAvailable
		      '_testAssert writer.Write("abcd") = 4
		      '_testAssert reader.HasDataAvailable
		      '_testAssert reader.Read(4,s)
		      '_testAssert s = "abcd"
		      'end if
		    end if
		    
		    // Test CFBundle and CFPropertyList
		    if true then
		      dim bndl as CFBundle = CFBundle.Application
		      dim infodict as CFDictionary = bndl.InfoDictionary
		      _testAssert not CFPropertyList(infodict).IsValid(kCFPropertyListXMLFormat_v1_0) // it's a CFDictionary but not a true CFPropertyList
		      _testAssert infodict.Value(CFString("CFBundleIdentifier")) = bndl.InfoDictionaryValue("CFBundleIdentifier")
		      dim url as new CFURL (bndl.URL, "Contents/Info.plist")
		      dim cfStr as CFString = CFString("CFBundleInfoPlistURL")
		      dim url2 as CFURL = CFURL(infodict.Value(cfStr))
		      _testAssert url.StringValue = url2.StringValue, url.StringValue+" <> "+url2.StringValue
		      dim rs as new CFReadStream (url)
		      _testAssert rs.Open
		      dim format as Integer, errorMessage as String
		      dim plist as CFPropertyList = NewCFPropertyList (rs, kCFPropertyListMutableContainersAndLeaves, format, errorMessage)
		      _testAssert errorMessage="", errorMessage
		      _testAssert plist.IsValid (format)
		      dim xml as String
		      xml = plist.XMLValue
		      plist = NewCFPropertyList (xml, kCFPropertyListMutableContainersAndLeaves, errorMessage)
		      _testAssert errorMessage="", errorMessage
		      _testAssert plist.XMLValue = xml
		      CFMutableDictionary(plist).Value(CFString("_AddedKVP_")) = CFString("test value")
		      _testAssert plist.XMLValue <> xml
		      dim ws as new CFWriteStream(url)
		      _testAssert ws.Open
		      _testAssert plist.Write (ws, kCFPropertyListBinaryFormat_v1_0, errorMessage) // this should write a binary plist but it actually writes an xml one. Odd
		      ws.Close
		      rs = new CFReadStream (url)
		      _testAssert rs.Open
		      _testAssert rs.Read(99999, s)
		      _testAssert s.InStr("test value") > 0
		    end
		    
		    // Test CFSocket (TCP/IP)
		    #if false then
		      // (TT 6 Dec 09) this is not working - at least not when reading and writing within same process
		      declare function CFRunLoopGetCurrent lib CarbonLib () as Ptr
		      declare sub CFReadStreamScheduleWithRunLoop lib CarbonLib (streamRef as Ptr, runLoopRef as Ptr, mode as CFStringRef)
		      declare sub CFWriteStreamScheduleWithRunLoop lib CarbonLib (streamRef as Ptr, runLoopRef as Ptr, mode as CFStringRef)
		      
		      dim serverSocket, clientSocket as CFSocket
		      dim serverReader, clientReader as CFReadStream
		      dim serverWriter, clientWriter as CFWriteStream
		      
		      dim myAddr as CFData = CFSocket.IP4Address("localhost", 26214)
		      
		      // set up the server streams
		      serverSocket = new CFSocket (CFSocket.PF_INET, CFSocket.SOCK_STREAM, CFSocket.IPPROTO_TCP, CFSocket.kAcceptCallBack)
		      _testAssert serverSocket.Bind(myAddr), "bind" // -> listen on socket
		      
		      // set up the client streams
		      CFStream.NewBoundPairFromHostAddress ("localhost", 26214, clientReader, clientWriter)
		      
		      _testAssert clientReader.Open
		      _testAssert clientWriter.Open
		      
		      CFWriteStreamScheduleWithRunLoop (clientWriter, CFRunLoopGetCurrent(), CFConstant("kCFRunLoopCommonModes"))
		      
		      App.DoEvents
		      
		      dim n as Integer = clientWriter.Write("start")
		      _testAssert n = 5
		      
		      do
		        App.DoEvents
		        if serverSocket.HasConnected and serverReader = nil then
		          CFStream.NewBoundPairFromNativeSocket (serverSocket.NativeHandle, serverReader, serverWriter)
		          
		          CFReadStreamScheduleWithRunLoop (serverReader, CFRunLoopGetCurrent(), CFConstant("kCFRunLoopCommonModes"))
		          
		          _testAssert serverReader.Open
		          _testAssert serverWriter.Open
		          
		          App.DoEvents
		          
		          _testAssert clientWriter.Write("hello") = 5
		        end
		        if serverReader <> nil and serverReader.HasDataAvailable then
		          if serverReader.Read(4,s) then
		            break
		          end if
		        end if
		      loop
		      
		      break
		    #endif
		    
		    // Test CFSockets (Unix Domain Sockets)
		    #if false then
		      // (TT 6 Dec 09) this is not working - at least not when reading and writing within same process
		      declare function CFRunLoopGetCurrent lib CarbonLib () as Ptr
		      declare sub CFReadStreamScheduleWithRunLoop lib CarbonLib (streamRef as Ptr, runLoopRef as Ptr, mode as CFStringRef)
		      declare sub CFWriteStreamScheduleWithRunLoop lib CarbonLib (streamRef as Ptr, runLoopRef as Ptr, mode as CFStringRef)
		      
		      dim serverSocket, clientSocket as CFSocket
		      dim serverReader, clientReader as CFReadStream
		      dim serverWriter, clientWriter as CFWriteStream
		      
		      dim path as String = "/var/tmp/cftest_socket_file"
		      dim f as FolderItem = GetFolderItem(path, FolderItem.PathTypeShell)
		      f.Delete
		      _testAssert not f.Exists
		      
		      dim ssig as new CFSocketSignature (path)
		      serverSocket = new CFSocket (ssig, CFSocket.kNoCallBack, false)
		      _testAssert not serverSocket.IsNULL
		      _testAssert serverSocket.IsValid
		      _testAssert f.Exists
		      
		      '_testAssert serverSocket.Bind(ssig.address), "bind" // -> listen on socket
		      
		      clientSocket = new CFSocket (ssig, CFSocket.kNoCallBack, true)
		      _testAssert not clientSocket.IsNULL
		      _testAssert clientSocket.IsValid
		      
		      'not working: CFStream.NewBoundPairFromSocket ssig, reader, writer
		      CFStream.NewBoundPairFromNativeSocket (clientSocket.NativeHandle, clientReader, clientWriter)
		      CFStream.NewBoundPairFromNativeSocket (serverSocket.NativeHandle, serverReader, serverWriter)
		      
		      CFReadStreamScheduleWithRunLoop (serverReader, CFRunLoopGetCurrent(), CFConstant("kCFRunLoopCommonModes"))
		      CFWriteStreamScheduleWithRunLoop (clientWriter, CFRunLoopGetCurrent(), CFConstant("kCFRunLoopCommonModes"))
		      
		      _testAssert serverReader.Open
		      _testAssert clientWriter.Open
		      
		      App.DoEvents
		      _testAssert not serverReader.HasDataAvailable
		      '_testAssert clientWriter.IsReady
		      _testAssert clientWriter.Write("abcd") = 4
		      App.DoEvents
		      _testAssert serverReader.HasDataAvailable
		      _testAssert serverReader.Read(4,s)
		      _testAssert s = "abcd"
		      
		      f.Delete
		      _testAssert not f.Exists
		    #endif
		    
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NewCFPropertyList(openedStream as CFReadStream, mutability as Integer, ByRef formatOut as Integer, ByRef errorMessageOut as String) As CFPropertyList
		  // mutability: kCFPropertyListImmutable, kCFPropertyListMutableContainers, kCFPropertyListMutableContainersAndLeaves
		  // Note: Returns nil if the xml data is not a valid property list
		  
		  dim pList as CFType
		  
		  #if TargetMacOS
		    declare function CFPropertyListCreateFromStream Lib CarbonLib (allocator as Ptr, readStream as Ptr, streamLen as Integer, mutabilityOptions as Integer, ByRef format as Integer, ByRef errMsg as CFStringRef) as Ptr
		    
		    dim theRef as Ptr
		    dim strRef as CFStringRef
		    theRef = CFPropertyListCreateFromStream (nil, openedStream.Reference, 0, mutability, formatOut, strRef)
		    if theRef <> nil then
		      pList = CFType.NewObject(theRef, true, mutability)
		      errorMessageOut = ""
		    else
		      errorMessageOut = strRef
		    end if
		  #else
		    errorMessageOut = "not supported on this platform"
		  #endif
		  
		  return CFPropertyList(pList)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Write(extends propertyList as CFPropertyList, openedWriteStream as CFWriteStream, format as Integer, ByRef errorMessageOut as String) As Boolean
		  #if TargetMacOS
		    soft declare function CFPropertyListWriteToStream lib CarbonLib (propertyList as Ptr, stream as Ptr, format as Integer, ByRef errMsg as CFStringRef) as Integer
		    
		    dim strRef as CFStringRef
		    dim written as Integer = CFPropertyListWriteToStream (propertyList.Reference, openedWriteStream.Reference, format, strRef)
		    errorMessageOut = strRef
		    if errorMessageOut = "" then
		      // success
		      return written > 0
		    end if
		  #else
		    errorMessageOut = "not supported on this platform"
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFTypeID(id as UInt32) As CFTypeID
		  dim tid as CFTypeID
		  tid.opaque = id
		  return tid
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CFURL(f as FolderItem) As CFURL
		  return new CFURL(f)
		End Function
	#tag EndMethod


	#tag Note, Name = About
		CFType and its subclasses are wrappers for Mac OS's CoreFoundation classes, which encompass
		numbers, strings, arrays, dictionaries and a few more common types. The CoreGraphics module
		also makes use of, and extends, these classes.
		
		As a first time user, start looking at CFPreferences to read/write your app's ".plist" prefs file,
		and at CFBundle, using its Application() method to get to your app bundle's folders (those
		hidden in your app package).
		
		Important: If you are adding or modifying new functionality using Declare statements,
		make sure you understand the reference counting rules. Read the "Memory Management"
		note in the CFType class for a start.
		
		Original sources are located here:  http://code.google.com/p/macoslib
	#tag EndNote

	#tag Note, Name = Comparing values
		There are three ways to compare objects of CFType and their subclasses:
		
		1. As they're objects, one may want to see if two RB variables identify the same
		   RB object, or if one is nil. To test this, use the "is" operator, e.g.:
		
		     if cfDict.Value(x) is nil then ... // tests if a dictionary entry exists
		
		2. As they reference a CoreFoundation object managed by OS X, one can test
		   if two RB objects reference the same CF object. Use the "="operator for this
		   (this is achieved by the Operator_Compare() function in the CFType class):
		
		     if cfArray.Value(i) = item then ... // test if item is already in the array
		
		   A special case is the NULL CF reference. To test if a CF class identifies
		   no CF object, you can use the IsNULL function.
		
		3. Finally, all CF objects refer to data (unless IsNULL() returns true). To access
		   that data, you need to retrieve it explicitly (exception: CFStrings can be
		   automatically coerced into Strings and vice versa).
		   In general, to check if two separate CF objects are equal, use the
		   Equals() function:
		
		     if cfNum1.Equals (cfNum2) then ... // test if their values are equal
		
		   Additionally, to order two CFNumber values, you cannot use "<" and
		   ">" on the CF objects but must compare their explicit values instead:
		
		     if n1.IntegerValue > n2.IntegerValue then ... // number compare
	#tag EndNote

	#tag Note, Name = NULL references ( nil ptrs )
		New rule implemented on 23 Dec 08:
		
		If a CF... class gets constructed from a nil reference, it will still be created
		(as a CFType whose IsNULL() function returns true).
		That way, you can always expect that a function that returns CF type values
		will get you an existing object and not nil. To test if the reference is nil,
		call the IsNULL() member function.
		Note, however, that CFDictionary.Value and CFPreferences.Value may still
		return nil if the given key does not exist in the dictionary or prefs.
	#tag EndNote


	#tag Constant, Name = kCFPropertyListImmutable, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCFPropertyListMutableContainers, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCFPropertyListMutableContainersAndLeaves, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCFPropertyListOpenStepFormat, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCFPropertyListXMLFormat_v1_0, Type = Double, Dynamic = False, Default = \"100", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCFPropertyListBinaryFormat_v1_0, Type = Double, Dynamic = False, Default = \"200", Scope = Public
	#tag EndConstant

	#tag Constant, Name = CarbonBundleID, Type = String, Dynamic = False, Default = \"com.apple.Carbon", Scope = Public
	#tag EndConstant

	#tag Constant, Name = CarbonLib, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac Carbon PEF, Language = Default, Definition  = \"CarbonLib"
		#Tag Instance, Platform = Mac Mach-O, Language = Default, Definition  = \"Carbon.framework"
	#tag EndConstant


	#tag Structure, Name = CFRange, Flags = &h0
		location as Int32
		length as Int32
	#tag EndStructure

	#tag Structure, Name = CFSocketNativeHandle, Flags = &h0
		handle As Int32
	#tag EndStructure

	#tag Structure, Name = CFTypeID, Flags = &h0
		opaque as UInt32
	#tag EndStructure

	#tag Structure, Name = CFSocketContext, Flags = &h0
		version as Int32
		  info as Integer
		  retainFunc as Ptr
		  releaseFunc as Ptr
		copyDescFunc as Ptr
	#tag EndStructure


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
