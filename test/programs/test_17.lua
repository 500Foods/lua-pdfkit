-- test_17 -- AcroForm: field tree, text, choice, button, formats, document JavaScript
--
-- The Lua mirror of test_17.js. Everything inside GeneratePDF() is pdfkit
-- API surface. Everything outside it is plumbing.

local ROOT do
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    local dir = src:match("^(.*)/") or "."
    ROOT = dir .. "/../.."
end
package.path = ROOT .. "/src/?.lua;" .. ROOT .. "/src/?/init.lua;" .. package.path

local PDFDocument = require("pdfkit")

local function GeneratePDF()
    local doc = PDFDocument.new({
        size = "LETTER",
        layout = "portrait",
    })

    doc:font("Helvetica")
    doc:initForm()

    local rootField = doc:formField("rootField")
    doc:font("Courier")
    local child1Field = doc:formField("child1Field", { parent = rootField })
    doc:font("Helvetica")
    local child2Field = doc:formField("child2Field", { parent = rootField })

    local y = 36
    doc:formText("leaf1", 72, y, 200, 20, {
        parent = child1Field,
        value = "1999-12-31",
        format = { type = "date", param = "yyyy-mm-dd" },
        align = "center",
    })

    y = y + 28
    doc:formText("dollar", 72, y, 200, 20, {
        parent = child1Field,
        value = 32.98,
        format = {
            type = "number",
            nDec = 2,
            sepComma = true,
            negStyle = "ParensRed",
            currency = "$",
            currencyPrepend = true,
        },
        align = "right",
    })

    y = y + 28
    doc:formText("leaf2", 72, y, 200, 40, {
        parent = child1Field,
        multiline = true,
        align = "right",
    })

    y = y + 48
    doc:formText("leaf3", 72, y, 200, 36, {
        parent = child2Field,
        multiline = true,
        value = "second child",
    })

    y = y + 44
    doc:formText("when", 72, y, 120, 18, {
        format = { type = "time", param = 2 },
        value = "14:30:15",
        align = "center",
    })

    y = y + 26
    doc:formText("pct", 72, y, 80, 18, {
        format = { type = "percent", nDec = 1 },
        value = "12.5",
    })
    doc:formText("zip", 160, y, 80, 18, {
        format = { type = "zip" },
        value = "02139",
    })
    doc:formText("phone", 250, y, 110, 18, {
        format = { type = "phone" },
        value = "6175551212",
    })

    y = y + 28
    doc:formPushButton("btn1", 72, y, 100, 24, {
        backgroundColor = "yellow",
        label = "Test Button",
    })

    y = y + 34
    doc:formCombo("ch1", 72, y, 140, 18, {
        borderColor = "black",
        select = { "Select Option", "github", "bitbucket", "gitlab" },
        value = "Select Option",
        defaultValue = "Select Option",
        align = "center",
        edit = true,
    })

    y = y + 28
    doc:formList("ch2", 72, y, 140, 48, {
        borderColor = "#808080",
        select = { "github", "bitbucket", "gitlab", "sourcesafe", "perforce" },
        sort = true,
    })

    y = y + 58
    doc:formCheckbox("agree", 72, y, 14, 14, {
        value = "Yes",
        backgroundColor = { 230, 230, 230 },
    })
    doc:formRadioButton("colour", 100, y, 14, 14, {
        value = "red",
        AS = "red",
    })
    doc:formRadioButton("colour", 124, y, 14, 14, {
        value = "blue",
        toggleToOffButton = true,
    })

    doc:fontSize(10)
    doc:text("a labelled form", 72, y + 22)

    doc:addNamedJavaScript("name1", "my javascript goes here")

    doc:addPage()
    doc:font("Times-Roman")
    doc:formText("page2note", 72, 72, 240, 36, {
        multiline = true,
        required = true,
        noExport = true,
        fontSize = 11,
        value = "required on page two",
    })

    return doc
end

local outPath = assert(arg[1], "usage: lua program.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
