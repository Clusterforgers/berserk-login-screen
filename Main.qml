import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Particles 2.15
import SddmComponents 2.0 as Sddm

Rectangle {
    id: root
    width: 1920
    height: 1200
    color: "black"

    readonly property color accent: "#c4161c"
    readonly property color textColor: "#d8d8d8"
    property int sessionIndex: sessionModel.lastIndex

    Sddm.TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            errorText.text = textConstants.loginFailed
            shake.start()
            password.forceActiveFocus()
        }
        function onLoginSucceeded() {
            errorText.text = ""
        }
    }

    // --- Background ---------------------------------------------------------
    // The wallpaper is split into layers laid out on a 1920x1200 stage
    // (the coordinates they were cut from), scaled to fit the screen.
    Item {
        id: stage
        width: 1920
        height: 1200
        anchors.centerIn: parent
        scale: Math.min(root.width / width, root.height / height)

        Image {
            id: handLeft
            x: 0; y: 690
            source: "hand_left.png"
            smooth: true
            transform: [
                Translate { id: slideLeft; x: -760; y: 260 },
                Translate { id: floatLeft }
            ]
        }

        Image {
            id: handRight
            x: 1410; y: 50
            source: "hand_right.png"
            smooth: true
            transform: [
                Translate { id: slideRight; x: 560; y: -300 },
                Translate { id: floatRight }
            ]
        }

        Item {
            id: brand
            x: 820; y: 340
            width: logo.width
            height: logo.height
            opacity: 0
            scale: 1.08

            Image { id: logo; source: "logo.png"; smooth: true }

            // Drip points, in logo-local coordinates
            BloodDrip { x: 141; y: 448; w: 4; fall: 140; minPause: 900;  maxPause: 2600; active: root.dripping }  // spike tip
            BloodDrip { x: 127; y: 383; w: 5; fall: 190; minPause: 2500; maxPause: 6000; active: root.dripping }  // beside spike
            BloodDrip { x: 64;  y: 293; w: 6; fall: 280; minPause: 3000; maxPause: 7500; active: root.dripping }  // diamond left corner
            BloodDrip { x: 213; y: 291; w: 6; fall: 280; minPause: 3500; maxPause: 8000; active: root.dripping }  // diamond right corner
            BloodDrip { x: 96;  y: 323; w: 5; fall: 250; minPause: 4000; maxPause: 9000; active: root.dripping }  // lower-left edge
            BloodDrip { x: 209; y: 179; w: 5; fall: 390; minPause: 5000; maxPause: 11000; active: root.dripping } // right prong
        }
    }

    property bool dripping: false

    // Intro: hands slide in and reach toward each other, then the brand appears.
    SequentialAnimation {
        running: true
        PauseAnimation { duration: 250 }
        ParallelAnimation {
            NumberAnimation { target: slideLeft;  properties: "x,y"; to: 0; duration: 2400; easing.type: Easing.OutCubic }
            NumberAnimation { target: slideRight; properties: "x,y"; to: 0; duration: 2400; easing.type: Easing.OutCubic }
            SequentialAnimation {
                PauseAnimation { duration: 1500 }
                ParallelAnimation {
                    NumberAnimation { target: brand; property: "opacity"; to: 1; duration: 1600; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: brand; property: "scale"; to: 1; duration: 2000; easing.type: Easing.OutCubic }
                }
            }
        }
        ScriptAction { script: { root.dripping = true; idleLeft.start(); idleRight.start() } }
    }

    // Slow idle drift once the hands are in place
    SequentialAnimation {
        id: idleLeft
        loops: Animation.Infinite
        NumberAnimation { target: floatLeft; property: "y"; to: -7; duration: 3800; easing.type: Easing.InOutSine }
        NumberAnimation { target: floatLeft; property: "y"; to: 0;  duration: 3800; easing.type: Easing.InOutSine }
    }
    SequentialAnimation {
        id: idleRight
        loops: Animation.Infinite
        NumberAnimation { target: floatRight; property: "y"; to: 6; duration: 4600; easing.type: Easing.InOutSine }
        NumberAnimation { target: floatRight; property: "y"; to: 0; duration: 4600; easing.type: Easing.InOutSine }
    }

    // --- Rain ---------------------------------------------------------------
    ParticleSystem { id: rain }

    // Far layer: small, faint, slower
    ImageParticle {
        system: rain
        groups: ["far"]
        source: "raindrop.png"
        rotation: 8
        opacity: 0.35
    }
    Emitter {
        system: rain
        group: "far"
        x: -root.width * 0.1
        y: -60
        width: root.width * 1.2
        height: 1
        emitRate: 260
        lifeSpan: 1600
        size: 28
        sizeVariation: 8
        velocity: AngleDirection { angle: 98; magnitude: 1000; magnitudeVariation: 150 }
    }

    // Near layer: larger, brighter, faster
    ImageParticle {
        system: rain
        groups: ["near"]
        source: "raindrop.png"
        rotation: 8
        opacity: 0.6
    }
    Emitter {
        system: rain
        group: "near"
        x: -root.width * 0.1
        y: -120
        width: root.width * 1.2
        height: 1
        emitRate: 90
        lifeSpan: 1000
        size: 60
        sizeVariation: 16
        velocity: AngleDirection { angle: 98; magnitude: 1700; magnitudeVariation: 250 }
    }

    // Occasional faint lightning flash
    Rectangle {
        id: flash
        anchors.fill: parent
        color: "#cfd8ff"
        opacity: 0
    }
    SequentialAnimation {
        id: lightning
        NumberAnimation { target: flash; property: "opacity"; to: 0.10; duration: 60 }
        NumberAnimation { target: flash; property: "opacity"; to: 0.0; duration: 90 }
        NumberAnimation { target: flash; property: "opacity"; to: 0.16; duration: 50 }
        NumberAnimation { target: flash; property: "opacity"; to: 0.0; duration: 600; easing.type: Easing.OutQuad }
    }
    Timer {
        running: true
        repeat: true
        interval: 9000
        onTriggered: {
            lightning.start()
            interval = 7000 + Math.random() * 14000
        }
    }

    // --- Clock (top center) -------------------------------------------------
    Column {
        anchors.top: parent.top
        anchors.topMargin: root.height * 0.06
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.textColor
            font.family: "Noto Serif"
            font.pixelSize: 64
            font.letterSpacing: 4
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        Text {
            id: date
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#8a8a8a"
            font.family: "Noto Serif"
            font.pixelSize: 18
            font.letterSpacing: 3
            text: Qt.formatDate(new Date(), "dddd, d MMMM").toUpperCase()
        }
        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: {
                clock.text = Qt.formatTime(new Date(), "HH:mm")
                date.text = Qt.formatDate(new Date(), "dddd, d MMMM").toUpperCase()
            }
        }
    }

    // --- Login form (bottom center) -----------------------------------------
    Column {
        id: form
        width: 340
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.height * 0.10
        spacing: 14

        transform: Translate { id: shakeOffset; x: 0 }

        TextField {
            id: username
            width: parent.width
            height: 44
            text: userModel.lastUser
            placeholderText: textConstants.userName
            placeholderTextColor: "#666"
            color: root.textColor
            font.pixelSize: 16
            font.family: "Noto Serif"
            horizontalAlignment: TextInput.AlignHCenter
            background: Rectangle {
                color: "#aa000000"
                border.width: 1
                border.color: username.activeFocus ? root.accent : "#333"
                radius: 2
            }
            KeyNavigation.tab: password
            Keys.onReturnPressed: password.forceActiveFocus()
            Keys.onEnterPressed: password.forceActiveFocus()
        }

        TextField {
            id: password
            width: parent.width
            height: 44
            echoMode: TextInput.Password
            passwordCharacter: "•"
            placeholderText: textConstants.password
            placeholderTextColor: "#666"
            color: root.textColor
            font.pixelSize: 16
            horizontalAlignment: TextInput.AlignHCenter
            focus: true
            background: Rectangle {
                color: "#aa000000"
                border.width: 1
                border.color: password.activeFocus ? root.accent : "#333"
                radius: 2
            }
            KeyNavigation.backtab: username
            Keys.onReturnPressed: root.doLogin()
            Keys.onEnterPressed: root.doLogin()
        }

        Text {
            id: errorText
            width: parent.width
            height: 18
            horizontalAlignment: Text.AlignHCenter
            color: root.accent
            font.pixelSize: 13
            font.family: "Noto Serif"
            text: ""
        }
    }

    SequentialAnimation {
        id: shake
        NumberAnimation { target: shakeOffset; property: "x"; to: -12; duration: 50 }
        NumberAnimation { target: shakeOffset; property: "x"; to: 12; duration: 70 }
        NumberAnimation { target: shakeOffset; property: "x"; to: -8; duration: 60 }
        NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 50 }
    }

    function doLogin() {
        errorText.text = ""
        sddm.login(username.text, password.text, root.sessionIndex)
    }

    // --- Bottom bar: session picker + power ---------------------------------
    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Session"
            color: "#777"
            font.pixelSize: 13
            font.family: "Noto Serif"
        }
        ComboBox {
            id: session
            width: 220
            height: 32
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex
            onActivated: root.sessionIndex = currentIndex
            font.pixelSize: 13
            contentItem: Text {
                leftPadding: 10
                text: session.displayText
                color: "#aaa"
                font: session.font
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            background: Rectangle {
                color: "#aa000000"
                border.width: 1
                border.color: session.activeFocus ? root.accent : "#333"
                radius: 2
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 18

        component PowerButton: Text {
            id: btn
            signal clicked()
            color: area.containsMouse ? root.accent : "#777"
            font.pixelSize: 13
            font.family: "Noto Serif"
            font.letterSpacing: 2
            MouseArea {
                id: area
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: btn.clicked()
            }
        }

        PowerButton {
            visible: sddm.canSuspend
            text: "SUSPEND"
            onClicked: sddm.suspend()
        }
        PowerButton {
            visible: sddm.canReboot
            text: "REBOOT"
            onClicked: sddm.reboot()
        }
        PowerButton {
            visible: sddm.canPowerOff
            text: "SHUT DOWN"
            onClicked: sddm.powerOff()
        }
    }

    Component.onCompleted: {
        if (username.text === "")
            username.forceActiveFocus()
        else
            password.forceActiveFocus()
    }
}
