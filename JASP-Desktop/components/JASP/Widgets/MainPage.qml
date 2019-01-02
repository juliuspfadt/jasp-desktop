import QtQuick 2.11
import QtWebEngine 1.7
import QtWebChannel 1.0
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4 as OLD
import QtQuick.Layouts 1.3
import JASP.Theme 1.0
import JASP.Widgets 1.0

OLD.SplitView
{
	id:				panelSplit
	orientation:	Qt.Horizontal

	Item
	{
		id:						dataAndAnalyses
		//Layout.fillWidth:		mainWindow.dataPanelVisible
		Layout.minimumWidth:	analyses.width
		Layout.maximumWidth:	maxWidth
		visible:				mainWindow.dataPanelVisible || analyses.visible
		//width:
		//implicitWidth:			//mainWindow.dataPanelVisible ?
			//						panelSplit.width / 2 //: analyses.width

		property real maxWidth: panelSplit.width - Theme.minPanelWidth

		onVisibleChanged:
		{
			if(visible)
			{
				if(mainWindow.dataPanelVisible) //allowed to be bigger than analyses.width
				{
					width = panelSplit.width / 2
					maxWidth = Qt.binding(function(){ return panelSplit.width - Theme.minPanelWidth } )
				}
				else // only analyses (like for summary stats)
				{
					width = analyses.width
					maxWidth = Qt.binding(function(){ return analyses.width })
				}
			}
		}

		/*Connections
		{
			target:				mainWindow
			onDataPanelVisible:	if(mainWindow.dataPanelVisible) { dataAndAnalyses.width = panelSplit.width / 2 }
		}*/

		z: 1

		DataPanel
		{
			id:						data
			visible:				mainWindow.dataPanelVisible
			anchors.fill:			parent
			anchors.rightMargin:	analyses.extraSpace
			z:						1
		}

		MouseArea
		{
			visible:	mainWindow.analysesVisible || fileMenuModel.visible
			z:			6

			anchors
			{
				top:	parent.top
				bottom:	parent.bottom
				left:	parent.left
				right:	analyses.left
			}

			onClicked:
			{
				mainWindow.analysesVisible	= false
				fileMenuModel.visible		= false

				mouse.accepted = false
			}
		}

		AnalysisForms
		{
			id:				analyses
			z:				2
			visible:		analysesModel.count > 0

			anchors
			{
				top:		parent.top
				right:		parent.right
				bottom:		parent.bottom
			}
		}
	}

	WebEngineView
	{
		z:						3
		id:						resultsView
		url:					resultsJsInterface.resultsPageUrl
		implicitWidth:			Theme.resultWidth
		Layout.minimumWidth:	Theme.minPanelWidth

		Connections
		{
			target: resultsJsInterface

			onRunJavaScript:			{ resultsView.runJavaScript(js)	}
			onRunJavaScriptCallback:	{
				var res = undefined;
				resultsView.runJavaScript(js, function(result) { console.log(result); res = result; })
				return res;
			}
		}

		webChannel.registeredObjects: [ resultsJsInterfaceInterface ]

		Item
		{
			id:				resultsJsInterfaceInterface
			WebChannel.id:	"jasp"

			//Yeah I know this "resultsJsInterfaceInterface" looks a bit stupid but this honestly seems like the best way to make the current resultsJsInterface functions available to javascript without rewriting (more of) the structure of JASP-Desktop right now.
			// It would be much better to have resultsJsInterface be passed irectly though..
			// It also gives you an overview of the functions used in results html

			function openFileTab()							{ resultsJsInterface.openFileTab()							}
			function saveTextToFile(fileName, html)			{ resultsJsInterface.saveTextToFile(fileName, html)			}
			function analysisUnselected()					{ resultsJsInterface.analysisUnselected()					}
			function analysisSelected(id)					{ resultsJsInterface.analysisSelected(id)					}
			function analysisChangedDownstream(id, model)	{ resultsJsInterface.analysisChangedDownstream(id, model)	}
			function showAnalysesMenu(options)				{ resultsJsInterface.showAnalysesMenu(options)				}
			function updateUserData(id, key)				{ resultsJsInterface.updateUserData(id, key)				}
			function analysisSaveImage(id, options)			{ resultsJsInterface.analysisSaveImage(id, options)			}
			function analysisEditImage(id, options)			{ resultsJsInterface.analysisEditImage(id, options)			}
			function removeAnalysisRequest(id)				{ resultsJsInterface.removeAnalysisRequest(id)				}
			function pushToClipboard(mime, raw, coded)		{ resultsJsInterface.pushToClipboard(mime, raw, coded)		}
			function pushImageToClipboard(raw, coded)		{ resultsJsInterface.pushImageToClipboard(raw, coded)		}
			function simulatedMouseClick(x, y, count)		{ resultsJsInterface.simulatedMouseClick(x, y, count)		}
			function saveTempImage(index, path, base64)		{ resultsJsInterface.saveTempImage(index, path, base64)		}
			function getImageInBase64(index, path)			{ resultsJsInterface.getImageInBase64(index, path)			}
			function resultsDocumentChanged()				{ resultsJsInterface.resultsDocumentChanged()				}
			function displayMessageFromResults(msg)			{ resultsJsInterface.displayMessageFromResults(msg)			}
		}


	}
}
