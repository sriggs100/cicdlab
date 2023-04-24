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

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeSet;

@ToString
@EqualsAndHashCode
@Getter
@Setter
public class IsoMessage {

    private TreeSet<Integer> bitmaps = new TreeSet<>();

    private Map<Integer, IsoElement> isoElements = new HashMap<>();

    private final IsoMsgDefinition isoMsgDefinition;

    public IsoMessage(IsoMsgDefinition isoMsgDefinition)
    {
        this.isoMsgDefinition = isoMsgDefinition;
    }

    public IsoElementVariant getElement(int id)
    {
        return new IsoElementVariant(isoElements.get(id));
    }

    public boolean containsElement(int id)
    {
        return isoElements.containsKey(id);
    }

    public IsoElementVariant getMessageType()
    {
        return new IsoElementVariant(isoElements.get(0));
    }

    public void setMessageType(String msgType )
    {
        isoElements.put(0, new IsoElement(0, isoMsgDefinition.getElementDefinition(0), msgType.getBytes(), null, null ));
    }

    public void setElement(int elementId, String content )
    {
        isoElements.put(elementId, new IsoElement(0, isoMsgDefinition.getElementDefinition(elementId), content.getBytes(), null, null ));
    }

    public void setElement(int elementId, byte[] content )
    {
        isoElements.put(elementId, new IsoElement(0, isoMsgDefinition.getElementDefinition(elementId), Arrays.copyOf(content, content.length), null, null ));
    }

    public void removeElement(int elementId )
    {
        isoElements.remove(elementId);
    }

    public boolean isElementDefined(int elementId )
    {
        return isoMsgDefinition.getElementDefinition(elementId) != null;
    }
}
