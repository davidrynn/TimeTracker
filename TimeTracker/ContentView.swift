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
    
    let id = 0
    
    var timer = Timer()
    
    @State var title: String
    
    var started = false
    
    init(title: String) {
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

struct TrackerView: View {

    @ObservedObject var stopwatch: Stopwatch {
        didSet(newValue) {
            title = newValue.title
        }
    }
    @State var canEdit = false
    
    @State private var title = "New"
    
    var body: some View {
        VStack {
        HStack {
            Text(title)
            Spacer()
            Text(String.fromTimeInterval(time: self.stopwatch.counter))
        }.font(.largeTitle)
            .onTapGesture {
                self.stopwatch.toggleClock()
        }
        .onLongPressGesture {
            self.canEdit.toggle()
            }
            if self.canEdit {
                HStack {
                    TextField("Enter Title", text: $title, onCommit: { self.canEdit = false })
                    Spacer()

                }
            }
        }
    }
}

struct ContentView: View {

    @State var stopWatches: [Stopwatch] = getData() {
        didSet(newValue) {
            saveData(stopwatches: newValue)
        }
    }
    @State var isPresented = false
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(stopWatches) { stopwatch in
                        TrackerView(stopwatch: stopwatch)
                    }.onDelete(perform: delete(at:))
                }
                .navigationBarTitle("Timers")
                .navigationBarItems(trailing:
                    Button(action: addTracker ) {
                        Image(systemName: "plus")
            })
        }
    }
    
    func addTracker() {
        stopWatches.append(Stopwatch(title: "New"))
    }
    
    func delete(at offsets: IndexSet) {
        stopWatches.remove(atOffsets: offsets)
     }
    
    static func getData() -> [Stopwatch] {
        guard let decoded  = UserDefaults.standard.object(forKey: "stopwatches") as? Data,
            let decodedStopwatches = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Stopwatch]  else {
                return []
        }
        return decodedStopwatches
    }
    
    func saveData(stopwatches: [Stopwatch]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: stopwatches)
        UserDefaults.standard.setValue(data, forKey: "stopwatches")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
//<a href="https://www.freepik.com/free-photos-vectors/icon">Icon vector created by freepik - www.freepik.com</a>


extension String {
    static func fromTimeInterval(time: Int) -> String {
        let hours = time / 3600
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

struct TrackerStruct {
    let id: UUID
    let counterTime: Int
    let title: String
}
