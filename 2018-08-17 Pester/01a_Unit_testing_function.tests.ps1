describe 'Add-One' {

    $TestNumber = 1
    $result = Add-One -Number $TestNumber

    it 'should return 2' {
        $result | should be 2
    }

}