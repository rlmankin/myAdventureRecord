import SwiftUI


public struct RangeSlider: View {
	/// ` Slider` Binding min & max values
	@Binding var boundValue : FilterRange
	@State private var lowerXValue : CGFloat = 0.0
	@State private var upperXValue : CGFloat
	let label : String = "test"
	let sliderFrameWidth : Double = 450.0
	
	let thumbdiameter : CGFloat = 15
	
	init(boundValue : Binding<FilterRange>,
		 sliderFrameWidth : Double ) {
		self._boundValue = boundValue
		self.upperXValue = sliderFrameWidth-thumbdiameter/2
	}
	
	

	public var body: some View {
		
		let rangeSpan = boundValue.baseRange.upperBound - boundValue.baseRange.lowerBound
		let adjustedSliderWidth = sliderFrameWidth - thumbdiameter
		let sliderHeight : CGFloat = 3
		
		func lowerRangeOffset(xValue: CGFloat) -> CGFloat {
			let offset = xValue / adjustedSliderWidth * rangeSpan + boundValue.baseRange.lowerBound
			return offset
		}
		
		func upperRangeOffset(xValue: CGFloat) -> CGFloat {
			let offset = xValue / adjustedSliderWidth * rangeSpan
			return offset
		}
		timeStampLog(message: "-> RangeSlider \(boundValue.baseRange),\(boundValue.filterRange)")
		return
			VStack {
				
				
					// ZStack for the actual range slider view
				ZStack (alignment: Alignment(horizontal: .leading, vertical: .center)) {
					// base slider line should be the width of the Slider
					Rectangle()								// Base slider line
						.frame(width: adjustedSliderWidth, height: sliderHeight)
						.offset(x:thumbdiameter/2)
						.foregroundColor(Color.green)
					// lower bound thumb and text
					VStack(alignment: .center) {
						Circle()							//the lower thumb
							.frame(width: thumbdiameter, height: thumbdiameter)
							.offset(x: lowerXValue-thumbdiameter/2, y: thumbdiameter/2)		// center the circle on the rectancle
						Text(String(format: "%5.0f", boundValue.filterRange.lowerBound))		// the lower thumb value
							.foregroundColor(Color.white)
							.font(.footnote)
							.border(Color.green)
					}
						// when the user moves the thumb, gesture.onChange is activated.  calculate the lower bound
					.gesture(DragGesture().onChanged( { (value) in
						if value.location.x >= 0 &&
							value.location.x <= sliderFrameWidth &&
							value.location.x <= upperXValue{
							lowerXValue = (value.location.x > thumbdiameter/4 ? value.location.x : 0.0)
							//print("\(value.location.x), \(lowerRangeOffset(xValue: value.location.x)), \(lowerXValue)")
							boundValue.filterRange = Double(lowerRangeOffset(xValue: lowerXValue)) ... boundValue.filterRange.upperBound
						}
					}))
					
					//	upper bound thumb and text
					VStack(alignment: .center) {
						Circle()							//the upper thumb
							.frame(width: thumbdiameter, height: thumbdiameter)
							.offset(x:upperXValue-thumbdiameter/2, y: thumbdiameter/2)
						Text(String(format: "%5.0f", boundValue.filterRange.upperBound))		// the upper thumb value
							.foregroundColor(Color.white)
							.font(.footnote)
							.offset(x:adjustedSliderWidth - 1.5*thumbdiameter)
							.border(Color.green)
					}
					.gesture(DragGesture().onChanged( { (value) in
						if value.location.x >= 0 &&
							value.location.x <= adjustedSliderWidth &&
							value.location.x > lowerXValue {
							upperXValue = ( value.location.x > sliderFrameWidth-thumbdiameter/2 ? sliderFrameWidth-thumbdiameter/2 : value.location.x)
							print("\(value.location.x), \(upperRangeOffset(xValue: value.location.x)), \(upperXValue)")
							boundValue.filterRange = boundValue.filterRange.lowerBound ... Double(upperRangeOffset(xValue: value.location.x))
						}
					}))
					
					
				}//.frame(height: 50)
			}
	}
}

struct RangeSlider_Previews: PreviewProvider {
	static var previews: some View {
		let filtervar = FilterVars()
		
		let sliderWidth = 450.0
		RangeSlider(boundValue: .constant(filtervar.searchLength), sliderFrameWidth: sliderWidth)
		
	}
}
