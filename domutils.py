def GetTextFromElementNode(element, childNamePattern):
	children = element.getElementsByTagName(childNamePattern)
	texts = []
	for child in children:
		texts.append(GetText(child.childNodes))

	return texts

def GetText(nodelist):
    rc = ""
    for node in nodelist:
        if node.nodeType == node.TEXT_NODE:
            rc = rc + node.data
    return rc

def GetTextFromElement(element):
	text = ""
	child = element.firstChild
	while not child.nextSibling is None:
		child = child.nextSibling
		print child
		if child.nodeType == child.TEXT_NODE:
			text = text + child.data

	return text
