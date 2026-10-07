import QtQuick 2.15

// A single blood drip anchored at (x, y): a bead swells out of the logo,
// a drop breaks off and falls `fall` pixels while fading, then it repeats
// after a random pause.
Item {
    id: drip
    width: 0
    height: 0

    property bool active: false
    property real w: 6                 // bead width in px
    property real fall: 200            // how far the drop travels before vanishing
    property int minPause: 1500
    property int maxPause: 5000
    property color blood: "#c80002"

    readonly property real beadMin: w * 0.6
    readonly property real beadMax: w * 2.8

    Rectangle {
        id: bead
        x: -drip.w / 2
        y: -drip.w * 0.5               // start slightly inside the logo so the seam is hidden
        width: drip.w
        height: drip.beadMin
        radius: width / 2
        color: drip.blood
    }

    Rectangle {
        id: drop
        x: -width / 2
        width: drip.w * 1.25
        height: drip.w * 1.6
        radius: width / 2
        color: drip.blood
        opacity: 0
    }

    Timer {
        id: wait
        running: drip.active
        interval: drip.minPause + Math.random() * (drip.maxPause - drip.minPause)
        onTriggered: cycle.start()
    }

    SequentialAnimation {
        id: cycle

        // Swell
        NumberAnimation {
            target: bead; property: "height"
            to: drip.beadMax
            duration: 1400 + Math.random() * 1200
            easing.type: Easing.InOutSine
        }
        // Detach
        ScriptAction {
            script: {
                drop.y = bead.y + bead.height - drop.height
                drop.height = drip.w * 1.6
                drop.opacity = 1
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: bead; property: "height"
                to: drip.beadMin
                duration: 300
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: drop; property: "y"
                to: drip.fall
                duration: 220 + Math.sqrt(drip.fall) * 32   // roughly gravity-like
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: drop; property: "height"
                to: drip.w * 2.6
                duration: 400
                easing.type: Easing.OutQuad
            }
            SequentialAnimation {
                PauseAnimation { duration: (220 + Math.sqrt(drip.fall) * 32) * 0.6 }
                NumberAnimation {
                    target: drop; property: "opacity"
                    to: 0
                    duration: (220 + Math.sqrt(drip.fall) * 32) * 0.4
                }
            }
        }
        onFinished: {
            wait.interval = drip.minPause + Math.random() * (drip.maxPause - drip.minPause)
            wait.restart()
        }
    }
}
