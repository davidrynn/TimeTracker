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
    
    let id = UUID()
    
    var timer = Timer()
    
    @Published var title: String
    
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
    
    func toggle() {
        if started {
            started = false
            stop()
            return
        }
        started = true
        start()
    }
}
//
//@State private var name: String = "Tim"
//
//var body: some View {
//    VStack {
//        TextField("Enter your name", text: $name)
//        Text("Hello, \(name)!")
//    }
//}

struct TrackerView: View {

    @ObservedObject var stopwatch: Stopwatch
        { didSet(newValue) {
            title = newValue.title
        }
        
    }
    @State private var title: String = "Placeholder"
    
    var body: some View {
        HStack {
//            Text(self.stopwatch.title)
            TextField(self.stopwatch.title, text: $title)
            Spacer()
            Text("\(self.stopwatch.counter)")
        }.font(.largeTitle)
    }
}

struct ContentView: View {

    @State var stopWatches: [Stopwatch] = [Stopwatch(title: "first")]
    @State var isPresented = false
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(stopWatches) { stopwatch in
                    HStack {
                        TrackerView(stopwatch: stopwatch)
                            .onTapGesture {
                                stopwatch.toggle()
                            }
    //                        .onLongPressGesture {
    //                            stopwatch.title =
    //                        }
                        Text("Edit")
                            .onTapGesture {
                            self.isPresented = true
                            
                            }
                            .sheet(isPresented: self.$isPresented) {
                                Text(stopwatch.title)
                            }
                    }
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
        stopWatches.append(Stopwatch(title: "Placeholder"))
    }
    func delete(at offsets: IndexSet) {
        stopWatches.remove(atOffsets: offsets)
     }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
//<a href="https://www.freepik.com/free-photos-vectors/icon">Icon vector created by freepik - www.freepik.com</a>
