<cfoutput>
<html>
<head>
    <title>Lucee Test</title>
</head>
<body>
    <h1>Lucee CFML Engine Test</h1>
    <p>Current Time: #now()#</p>
    <p>Server Info: #server.lucee.version# (Lucee #server.coldfusion.productversion#)</p>
    <p>Date Format: #dateFormat(now(), "full")#</p>
    
    <h2>CFML Processing Test</h2>
    <cfset testVar = "Hello from Lucee!" />
    <p>Test Variable: #testVar#</p>
    
    <cfloop from="1" to="5" index="i">
        <p>Loop iteration: #i#</p>
    </cfloop>
    
    <h2>System Information</h2>
    <p>Operating System: #server.os.name#</p>
    <p>Java Version: #server.java.version#</p>
    
    <cfif structKeyExists(server, "lucee")>
        <p style="color: green; font-weight: bold;">✓ Lucee is running successfully!</p>
    <cfelse>
        <p style="color: red; font-weight: bold;">✗ Lucee is not detected</p>
    </cfif>
</body>
</html>
</cfoutput>