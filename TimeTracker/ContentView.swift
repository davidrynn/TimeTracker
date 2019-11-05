//
//  ContentView.swift
//  TimeTracker
//
//  Created by David Rynn on 10/22/19.
//  Copyright © 2019 David Rynn. All rights reserved.
//

import Combine
import SwiftUI

class Stopwatch: Identifiable, ObservableObject {
    
    @Published var counter: Int = 0
    
    let id: UUID
    
    var timer = Timer()
    
    var title: String
    
    var started = false
    
    init(id: UUID = UUID(), title: String = "New") {
        self.id = id
        self.title = title
    }
    
    func start() {
        started = true
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.counter += 1
            print(self.counter)
        }
    }
    
    func stop() {
        started = false
        timer.invalidate()
        print("stopped")
    }
    
    func reset() {
        counter = 0
        timer.invalidate()
    }
    
    func toggleClock() {
        if started {
            started = false
            stop()
            return
        }
        started = true
        start()
    }
}

struct TrackerModel: Identifiable {
    var counter: Int = 0
    var id: UUID = UUID()
    var isRunning: Bool = false
    let startTime: NSDate = NSDate()
    var stopTime: NSDate = NSDate()
    var title: String
}


struct TrackerView: View {
    
    @ObservedObject var stopwatch: Stopwatch
    @State var canEdit = false
    @State var isCounting = false
    @State var toggleColor = false
    var color: Color {
        return toggleColor ? .green : .clear
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter Title", text: $stopwatch.title, onCommit: { self.canEdit = false }).environment(\.isEnabled, self.canEdit)
                Spacer()
                Text(String.fromTimeInterval(time: self.stopwatch.counter))
            }
            .background(color)
            .font(.largeTitle)
            .onTapGesture {
                self.isCounting.toggle()
                self.stopwatch.toggleClock()
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.toggleColor.toggle()
                }
            }
            .onLongPressGesture {
                self.canEdit.toggle()
            }
        }
    }
}

struct ContentView: View {
    
    @State var stopWatches: [Stopwatch]
    @State var isPresented = false
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(stopWatches) { stopwatch in
                    TrackerView(stopwatch: stopwatch)
                }.onDelete(perform: delete(at:))
            }
            .navigationBarTitle("Timers")
            .navigationBarItems(
                leading:
                Button(action: { UserDefaults.save(stopwatches: self.stopWatches) }) {
                    Image(systemName: "archivebox")
                },
                trailing:
                Button(action: addTracker ) {
                    Image(systemName: "plus")
            })
        }
    }
    
    func addTracker() {
        stopWatches.append(Stopwatch())
    }
    
    func delete(at offsets: IndexSet) {
        stopWatches.remove(atOffsets: offsets)
    }
    

}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//<a href="https://www.freepik.com/free-photos-vectors/icon">Icon vector created by freepik - www.freepik.com</a>


extension String {
    static func fromTimeInterval(time: Int) -> String {
        let hours = time / 3600
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}
extension Date {
    func differenceInSeconds(_ time: Date) -> Int {
        let dateComponent: Calendar.Component = .second
        let set: Set = [dateComponent]
        return Calendar.current.dateComponents(set, from: self, to: time).second ?? 0
    }
}

struct TrackerStruct {
    let id: UUID
    let counterTime: Int
    let title: String
}

extension UserDefaults {
    
    static func save(stopwatches: [Stopwatch]) {
        let dict: NSArray = stopwatches.map {
            [ "id": ($0.id).uuidString,
              "title": $0.title as NSString,
              "counter": $0.counter
                ] as NSDictionary
            } as NSArray
        UserDefaults.standard.setValue(dict, forKey: "stopwatches")
    }
    
    func save(trackers: [TrackerModel]) {
        let dictArray: NSArray = trackers.map { trackerToDictionary($0) } as NSArray
        UserDefaults.standard.set(dictArray, forKey: "trackers")
    }
    
    
    private func trackerToDictionary(_ model: TrackerModel) -> [String: Any] {
        var dictionary = [String: Any]()
        Mirror(reflecting: TrackerModel.self).children.forEach {
            if let key = $0.label {
                dictionary[key] = $0.value
            }
        }
        return dictionary
    }
}
