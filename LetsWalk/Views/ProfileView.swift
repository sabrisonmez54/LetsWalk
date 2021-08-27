//
//  ProfileView.swift
//  LetsWalk
//
//  Created by Sabri Sönmez on 8/25/21.
//

import SwiftUI

struct ProfileView: View {
    let userHealthProfile : UserHealthProfile
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
            VStack{
                Text("Your Details:")
                Text(userHealthProfile.age.map { "Age: \($0)" } ?? "not set")
                Text("Sex: \(userHealthProfile.biologicalSex?.stringRepresentation ?? "not set")")
                Text("Blood Type: \(userHealthProfile.bloodType?.stringRepresentation ?? "not set")")
                Text("Height: \(userHealthProfile.heightInMeters ?? 0.0, specifier: "%.2f")m")
                Text("Weight: \(userHealthProfile.weightInKilograms ?? 0.0, specifier: "%.2f")kg")
                Text("BMI: \(userHealthProfile.bodyMassIndex ?? 0.0, specifier: "%.2f")")
            }
           
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userHealthProfile: UserHealthProfile.init(age: 18, biologicalSex: .female, bloodType: .aNegative, heightInMeters: 160, weightInKilograms: 65))
    }
}
