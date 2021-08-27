//
//  ContentView.swift
//  LetsWalk
//
//  Created by Sabri Sönmez on 8/24/21.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    private var healthStore: HealthStore?
    @State private var steps: [Step] = [Step]()
    @State var barChartArray = [(String,Double)]()
    @State private var userHealthProfile = UserHealthProfile()
    
    init() {
        healthStore = HealthStore()
    }
    
    private func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection) {
        
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let endDate = Date()
        
        statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
            
            let count = statistics.sumQuantity()?.doubleValue(for: .count())
            
            let step = Step(count: Int(count ?? 0), date: statistics.startDate)
            steps.append(step)
            
           
        }
        
        for i in steps {
            self.barChartArray.append((getStringFromDate(date: i.date), Double(i.count)))
        }

    }
    
    func getUserProfile(age: Int,
                        biologicalSex: HKBiologicalSex,
                        bloodType: HKBloodType) {
        userHealthProfile.age = age
        userHealthProfile.biologicalSex = biologicalSex
        userHealthProfile.bloodType = bloodType
    }
    
    private func loadAndDisplayMostRecentWeight(healthStore: HealthStore) {

      guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
        print("Body Mass Sample Type is no longer available in HealthKit")
        return
      }
      
        healthStore.getMostRecentSample(for: weightSampleType) { (sample, error) in
        
        guard let sample = sample else {
          
          if let error = error {
            print(error)
          }
          return
        }
        
        let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
        self.userHealthProfile.weightInKilograms = weightInKilograms
      }
    }

   
    var body: some View {
        
        NavigationView {
            VStack{
                HStack{
                    ProfileView(userHealthProfile: self.userHealthProfile)
                    VStack{
                        BarChartView(data: ChartData(values: barChartArray.reversed()), title: "Steps taken",legend:"for the past week")
                        Text("Total Steps: \(steps.map { $0.count }.reduce(0,+))")
                            .opacity(0.5)
                            .padding(.top)
                    }
                    
                }
                .padding()
                
                NavigationLink(destination: WorkoutView()) {
                                    Text("Workout")
                }
                
              
                    
            }
            
                .navigationTitle("Just Walking")
        }
        
        .onAppear {
            if let healthStore = healthStore {
                healthStore.requestAuthorization { success in
                    if success {
                        healthStore.calculateSteps { statisticsCollection in
                            if let statisticsCollection = statisticsCollection {
                                // update the UI
                                updateUIFromStatistics(statisticsCollection)
                                do {
                                    try getUserProfile(age: healthStore.getAgeSexAndBloodType().age, biologicalSex: healthStore.getAgeSexAndBloodType().biologicalSex, bloodType: healthStore.getAgeSexAndBloodType().bloodType)
                                }
                                catch let error {
                                  print(error)
                                }
                                guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
                                  print("Height Sample Type is no longer available in HealthKit")
                                  return
                                }
                                healthStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
                                    
                                    guard let sample = sample else {
                                    
                                      if let error = error {
                                        print(error)
                                      }
                                      
                                      return
                                    }
                                    
                                    //2. Convert the height sample to meters, save to the profile model,
                                    //   and update the user interface.
                                    let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
                                    userHealthProfile.heightInMeters = heightInMeters
                                  }
                                loadAndDisplayMostRecentWeight(healthStore: self.healthStore!)
                            }
                        }
                    }
                }
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
