/*
 * MIT License
 *
 * Copyright (c) 2022 Sergio Andres Penen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

package org.dissertation.iso8583;

import lombok.*;

import java.util.HexFormat;

@EqualsAndHashCode
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class IsoElement {

    private int elementId;
    private IsoElementDefinition isoElementDefinition;
    private byte[] rawContent;
    private Integer startPos;
    private Integer endPos;

    public String toString() {
        return "IsoElement(elementId=" + this.getElementId() +
                ", rawContent= " +
                (!isoElementDefinition.getEncoding().equals(IsoElementDefinition.ENCODING.ASCII) ? "HEX(" + HexFormat.of().formatHex(this.getRawContent()) + ") " : "") +
                (!isoElementDefinition.getEncoding().equals(IsoElementDefinition.ENCODING.BINARY) ? "/ BIN=(" + new String(this.getRawContent()) + ")" : "") +
                ", startPos=" + this.getStartPos() + ", endPos=" + this.getEndPos() + ")";
    }
}
