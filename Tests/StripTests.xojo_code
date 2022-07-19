#tag Class
Protected Class StripTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub CodePointsTest()
		  RunTest AddressOf StripCodePoints
		  
		End Sub
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h1
		Protected Delegate Function FunctionDelegate(s As String) As String
	#tag EndDelegateDeclaration

	#tag Method, Flags = &h0
		Sub MemoryBlockTest()
		  RunTest AddressOf StripMemoryBlock
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MiddleTest()
		  RunTest AddressOf StripMiddle
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NativeTest()
		  RunTest AddressOf StripNative
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RegExMatchTest()
		  RunTest AddressOf StripRegExMatch
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RegExReplaceTest()
		  RunTest AddressOf StripRegExReplace
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RunTest(func As FunctionDelegate)
		  var inOut() as pair
		  
		  inOut.Add "" : ""
		  inOut.Add "" : "  "
		  inOut.Add "" : "              "
		  inOut.Add "a" : "a"
		  inOut.Add "a" : "   a"
		  inOut.Add "a b" : "a b"
		  inOut.Add "a b" : "   a b"
		  inOut.Add "a b " : "   a b "
		  inOut.Add "a b" : &u00 + &u0D + &u0A + &u1F + "a b"
		  inOut.Add "some really long string with lots of leading spaces" : _
		  "                                                 some really long string with lots of leading spaces"
		  
		  StartTestTimer
		  
		  const kQuote as string = """"
		  
		  #if DebugBuild then
		    const kReps as integer = 1000
		  #else
		    const kReps as integer = 5000
		  #endif
		  
		  for reps as integer = 1 to kReps
		    for each p as pair in inOut
		      var expected as string = p.Left
		      var testValue as string = p.Right
		      var actual as string = func.Invoke( testValue )
		      if actual <> expected then
		        Assert.AreEqual expected, actual, kQuote + testValue + kQuote
		        return
		      end if
		    next p
		  next reps
		  
		  LogTestTimer
		  
		  Assert.Pass
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SplitTest()
		  RunTest AddressOf StripSplit
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripCodePoints(s As String) As String
		  var index as integer
		  for each cp as integer in s.Codepoints
		    if cp > 32 then
		      return s.Middle( index )
		    end if
		    index = index + 1
		  next
		  
		  return ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripMemoryBlock(s As String) As String
		  if s = "" then
		    return s
		  end if
		  
		  var origEncoding as TextEncoding = s.Encoding
		  var useEncoding as TextEncoding = if( origEncoding is nil, nil, Encodings.UTF8 )
		  
		  var mb as MemoryBlock = s.ConvertEncoding( useEncoding )
		  var p as ptr = mb
		  var lastByteIndex as integer = mb.Size - 1
		  
		  var result as string
		  
		  for byteIndex as integer = 0 to lastByteIndex
		    if p.Byte( byteIndex ) > 32 then
		      result = mb.StringValue( byteIndex, mb.Size - byteIndex, useEncoding )
		      exit
		    end if
		  next
		  
		  result = result.ConvertEncoding( origEncoding )
		  return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripMiddle(s As String) As String
		  var lastIndex as integer = s.Length - 1
		  for i as integer = 0 to lastIndex
		    var test as string = s.Middle( i, 1 )
		    if test > " " then
		      return s.Middle( i )
		    end if
		  next
		  
		  return ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripNative(s As String) As String
		  static badChars() as string
		  
		  if badChars.Count = 0 then
		    for i as integer = 0 to 31
		      badChars.Add Chr( i )
		    next
		  end if
		  
		  return s.TrimLeft( _
		  &u00, _
		  &u01, _
		  &u02, _
		  &u03, _
		  &u04, _
		  &u05, _
		  &u06, _
		  &u07, _
		  &u08, _
		  &u09, _
		  &u0A, _
		  &u0B, _
		  &u0C, _
		  &u0D, _
		  &u0E, _
		  &u0F, _
		  &u10, _
		  &u11, _
		  &u12, _
		  &u13, _
		  &u14, _
		  &u15, _
		  &u16, _
		  &u17, _
		  &u18, _
		  &u19, _
		  &u1A, _
		  &u1B, _
		  &u1C, _
		  &u1D, _
		  &u1E, _
		  &u1F, _
		  &u20 _
		   )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripRegExMatch(s As String) As String
		  static rx as RegEx
		  if rx is nil then
		    rx = new RegEx
		    rx.SearchPattern = "[\x21-\xFF][\s\S]*"
		  end if
		  
		  var match as RegExMatch = rx.Search( s )
		  if match isa object then
		    return match.SubExpressionString( 0 )
		  end if
		  
		  return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripRegExReplace(s As String) As String
		  static rx as RegEx
		  if rx is nil then
		    rx = new RegEx
		    rx.SearchPattern = "\A[\x00-\x20]+"
		  end if
		  
		  return rx.Replace( s )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripSplit(s As String) As String
		  var arr() as string = s.Split( "" )
		  var result as string
		  for i as integer = 0 to arr.LastIndex
		    if arr( i ) > " " then
		      result = s.Middle( i )
		      exit
		    end if
		  next i
		  
		  return result
		  
		End Function
	#tag EndMethod


End Class
#tag EndClass
