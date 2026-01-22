import Cocoa
import Foundation

// Bundle IDs per Cisco docs:
// <= 5.1.2.x: com.cisco.anyconnect.gui
// >= 5.1.3.x: com.cisco.secureclient.gui
let targetBundleIDs: Set<String> = [
    "com.cisco.anyconnect.gui",
    "com.cisco.secureclient.gui"
]

let umbrellactlPath = "/usr/local/bin/umbrellactl"

func toast(_ text: String) {
    // Simple macOS user notification
    let script = "display notification \(text.debugDescription) with title \"Umbrella toggle\""
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    task.arguments = ["-e", script]
    try? task.run()
}

@discardableResult
func runUmbrellaCtl(_ arg: String) -> Int32 {
    // Use sudo -n (non-interactive). This will fail if sudoers isn't set.
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
    task.arguments = ["-n", umbrellactlPath, arg]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    do {
        try task.run()
        task.waitUntilExit()
        return task.terminationStatus
    } catch {
        return 127
    }
}

func handleLaunch(of app: NSRunningApplication) {
    guard let bid = app.bundleIdentifier, targetBundleIDs.contains(bid) else { return }
    let rc = runUmbrellaCtl("-e")
    toast("Cisco Secure Client opened → umbrellactl -e (rc=\(rc))")
}

func handleTerminate(of app: NSRunningApplication) {
    guard let bid = app.bundleIdentifier, targetBundleIDs.contains(bid) else { return }
    let rc = runUmbrellaCtl("-d")
    toast("Cisco Secure Client closed → umbrellactl -d (rc=\(rc))")
}

let nc = NSWorkspace.shared.notificationCenter
nc.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil) { note in
    if let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
        handleLaunch(of: app)
    }
}
nc.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: nil) { note in
    if let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
        handleTerminate(of: app)
    }
}

// If Cisco Secure Client is already running when we start, enable immediately:
for app in NSWorkspace.shared.runningApplications {
    if let bid = app.bundleIdentifier, targetBundleIDs.contains(bid) {
        let rc = runUmbrellaCtl("-e")
        toast("Cisco Secure Client already running → umbrellactl -e (rc=\(rc))")
        break
    }
}

RunLoop.main.run()
